require 'auto_strip_attributes'

class Person < Fe::Person
  include Sidekiq::Worker
  include CruLib::GlobalRegistryMethods

  sidekiq_options unique: true

  auto_strip_attributes :first_name, :last_name, :preferred_name, :account_no, :title

  self.table_name = 'ministry_person'

  # SP-298
  has_many :sp_designation_numbers, dependent: :destroy

  # Summer Project
  has_many :sp_applications
  alias_method :applications, :sp_applications # form engine expects applications association

  has_one :current_application, -> { where("year = '#{SpApplication.year}'") }, class_name: '::SpApplication'
  has_many :sp_staff, class_name: 'SpStaff', foreign_key: 'person_id'
  has_many :sp_directorships, -> { where(type: SpStaff::DIRECTORSHIPS) }, class_name: 'SpStaff', foreign_key: 'person_id'
  has_many :directed_projects, through: :sp_directorships, source: :sp_project
  has_many :staffed_projects, through: :sp_staff, source: :sp_project
  has_many :current_staffed_projects, -> { where("sp_staff.year = #{SpApplication.year}").select('sp_projects.*') }, through: :sp_staff, source: :sp_project
  has_one :sp_user
  has_many :sp_application_moves, foreign_key: 'moved_by_person_id'

  belongs_to :user, foreign_key: 'fk_ssmUserId' # TODO need to migrate person columns to be more rails-like

  # General
  attr_accessor :school

  # validates_file_format_of :image, :in => ["image/jpeg", "image/gif"]
  validates_uniqueness_of :fk_ssmUserId, message: 'This username already has a person record.', allow_nil: true
  validates_presence_of :first_name

  accepts_nested_attributes_for :current_address, :current_application
  # validates_filesize_of :image, :in => 0..2.megabytes
  #

  before_save :check_region, :stamp_changed
  before_create :stamp_created

  scope :not_secure, -> { where("\"isSecure\" != 'T' or \"isSecure\" IS NULL") }

  alias_attribute :university_state, :universityState
  alias_attribute :year_in_school, :yearInSchool
  alias_attribute :is_child, :isChild
  alias_attribute :user_id, :fk_ssmUserId
  alias_attribute :changed_by, :changedBy

  def emergency_address
    emergency_address1
  end

  def emergency_address=(address)
    self.emergency_address1 = address
  end

  def create_emergency_address
    Address.create(person_id: id, address_type: 'emergency1')
  end

  def create_current_address
    Address.create(person_id: id, address_type: 'current')
  end

  def create_permanent_address
    Address.create(person_id: id, address_type: 'permanent')
  end

  def region(try_target_area = true)
    region = self[:region]
    region ||= target_area['region'] if try_target_area && target_area
    region
  end

  # def campus=(campus_name)
  # write_attribute("campus", campus_name)
  # if target_area
  # write_attribute("region", self.school.region)
  # self.univerityState = self.school.state
  # end
  # end

  def target_area
    return school if school.present?

    self.school =
      case
      when campus.present? && universityState.present?
        TargetArea.find_by(name: campus, state: universityState)
      when campus.present?
        TargetArea.find_by(name: campus)
      end
  end

  def human_gender
    return '' if gender.to_s.empty?
    is_male? ? 'Male' : 'Female'
  end

  def is_male?
    gender.to_i == 1
  end

  def is_female?
    gender.to_i == 0
  end

  def is_high_school?
    lastAttended == 'HighSchool'
  end

  # "first_name last_name"
  def full_name
    first_name.to_s  + ' ' + last_name.to_s
  end

  # "nickname last_name"
  def informal_full_name
    nickname.to_s  + ' ' + last_name.to_s
  end

  def name_with_nick
    name = []
    name << first_name.to_s
    if preferred_name.present? && preferred_name.strip != first_name.strip
      name << "(#{preferred_name.strip})"
    end
    name << last_name.to_s
    name.join(' ')
  end

  # "first_name middle_name last_name"
  def long_name
    l = first_name.to_s + ' '
    l += middle_name.to_s + ' ' if middle_name
    l + last_name.to_s
  end

  # a little more than an alias.  Nickname is the preferred_name if one is listed.  Otherwise it is first name
  def nickname
    (preferred_name && !preferred_name.strip.empty?) ? preferred_name : first_name
  end

  # nickname is an alias for preferred_name
  def nickname=(name)
    write_attribute('preferred_name', name)
  end

  # an alias for yearInSchool
  def year
    yearInSchool
  end

  def year=(y)
    write_attribute('yearInSchool', y)
  end

  def marital_status
    Person::MARITAL_STATUSES[maritalStatus]
  end

  MARITAL_STATUSES = { 'S' => 'Single',
                       'M' => 'Married',
                       'D' => 'Divorced',
                       'W' => 'Widowed',
                       'P' => 'Separated' }

  # set dateChanged and changedBy
  def stamp_changed
    return unless changed?

    self.dateChanged = Time.now
    self.changedBy = ApplicationController.application_name
  end

  # backwards compatibility
  def stamp
    stamp_changed
  end

  def stamp_created
    self.dateCreated = Time.now
    self.createdBy = ApplicationController.application_name
  end

  def email
    email_address
  end

  # def email_address
  #   current_address ? current_address.email : user.try(:username)
  # end

  # [email1, email2, email3] => primary email, or email
  def email_address
    (email_addresses.where(primary: true).first || email_addresses.first).try(:email) ||
      current_address.try(:email) ||
      permanent_address.try(:email) ||
      user.try(:username)
  end

  # Sets the primary email address in email_addresses table
  def primary_email_address=(email)
    old_primaries = email_addresses.select { |email| email.primary == true }
    old_primaries.each do |old_primary|
      old_primary.primary = 0
      old_primary.save!
    end

    old_email_record = email_addresses.select { |email_record| email_record.email == email }.first
    if old_email_record
      old_email_record.primary = 1
      old_email_record.save!
    else
      EmailAddress.create!(email: email, person_id: id, primary: 1)
    end
  end
  alias_method :email=, :primary_email_address=

  # Sets a phone number in the phone_numbers table
  def set_phone_number(phone, location, primary = false, extension = nil)
    if primary
      old_primaries = phone_numbers.select { |phone| phone.primary == true }
      old_primaries.each do |old_primary|
        old_primary.primary = 0
        old_primary.save!
      end
    end

    old_phone_record = phone_numbers.select { |phone| phone.location == location }.first
    if old_phone_record
      old_phone_record.number = phone
      old_phone_record.extension = extension
      old_phone_record.primary = primary
      old_phone_record.save!
    else
      PhoneNumber.create!(number: phone, location: location, extension: extension, primary: primary, person_id: id)
    end
  end

  # This method shouldn't be needed because nightly updater should fill this in
  def is_secure?
    isSecure == 'T'
  end

  # Find an exact match by email
  def self.find_exact(person, address)
    # try by email address first
    person = Person.where("#{Address.table_name}.email = ?", address.email).includes(:current_address).references(:current_address).first
    # then try by username
    person ||= Person.where("#{User.table_name}.username = ?", address.email).includes(:user).references(:user).first
    person
  end

  # Make sure account numbers are 9 or 10 digits long
  def self.fix_acct_no(acct_no)
    result = acct_no
    unless acct_no.blank?
      fix_length = 9
      if acct_no.ends_with?('S') || acct_no.ends_with?('s')
        fix_length = 10
      end
      pad = fix_length - acct_no.length
      result = '0' * pad + acct_no if pad > 0
    end
    result
  end

  #   def all_team_members(remove_self = false)
  #     my_local_level_ids = teams.collect &:id
  #     mmtm = TeamMember.get('filters[team_id]' => my_local_level_ids) #order("last_name, first_name ASC")
  #     people = mmtm.collect(&:person).flatten.uniq
  #     people.delete(self) if remove_self
  #     return people
  #   end

  def to_s
    informal_full_name
  end

  def apply_omniauth(omniauth)
    self.first_name ||= omniauth['first_name']
    self.last_name ||= omniauth['last_name']
  end

  def check_region
    if !self.isStaff? && self[:campus] && target_area && self[:region] != target_area.region
      self[:region] = target_area.region unless self[:region] == target_area.region
      self.universityState = target_area.state
    end
  end

  def phone
    if current_address
      return current_address.cell_phone if current_address.cell_phone.present?
      return current_address.home_phone if current_address.home_phone.present?
      return current_address.work_phone if current_address.work_phone.present?
    else
      ''
    end
  end

  # TODO: determine if we need this.. user has no balance_bookmark defined
  #   def account_balance
  #     result = nil
  #     if user && user.balance_bookmark
  #       result = user.balance_bookmark.value
  #     end
  #     result
  #   end

  def updated_at
    dateChanged
  end

  def updated_by
    changedBy
  end

  def created_at
    dateCreated
  end

  def created_by
    createdBy
  end

  def async_push_to_global_registry
    attributes_to_push['account_number'] = account_no
    attributes_to_push['gender'] = human_gender
    attributes_to_push['marital_status'] = marital_status
    attributes_to_push['is_secure'] = is_secure?
    if birth_date.present?
      year, month, day = birth_date.to_s(:db).split('-').map(&:to_i)
      if month > 0 && day > 0
        attributes_to_push['birth_year'] = year if year > 0
        attributes_to_push['birth_month'] = month
        attributes_to_push['birth_day'] = day
      end
    end

    attributes_to_push['authentication'] = {}

    if user
      attributes_to_push['authentication']['relay_guid'] = user.globallyUniqueID if user.globallyUniqueID.present?
      attributes_to_push['authentication']['facebook_uid'] = user.fb_user_id if user.fb_user_id.present?

      user.authentications.each do |authentication|
        case authentication.provider
        when 'facebook'
          attributes_to_push['authentication']['facebook_uid'] = authentication.uid
        when 'google_apps'
          attributes_to_push['authentication']['google_apps_uid'] = authentication.uid
        end
      end
    end

    super
  end

  def self.skip_fields_for_gr
    %w(id ministry strategy organization_tree_cache org_ids_cache siebel_contact_id account_no minor number_children is_child bio image occupation blogfeed cru_commons_invite cru_commons_last_login date_created date_changed created_by changed_by fk_ssm_user_id fk_staff_site_profile_id fk_spouse_id fk_child_of level_of_school staff_notes donor_number url primary_campus_involvement_id mentor_id last_attended fb_uid date_attributes_updated balance_daily sp_gcx_site birth_date global_registry_id)
  end

  def self.columns_to_push
    super
    unless @extended_columns_to_push
      @columns_to_push += [{ name: 'account_number', type: :string },
                           { name: 'username', type: :string },
                           { name: 'birth_year', type: :integer },
                           { name: 'birth_month', type: :integer },
                           { name: 'birth_day', type: :integer }
                          ]
      @extended_columns_to_push = true
      @columns_to_push.each do |column|
        column[:type] = 'boolean' if column[:name] == 'is_secure'
      end
    end
    @columns_to_push
  end

  def self.global_registry_entity_type_name
    'person'
  end

  def self.search_by_name(name, scope = Person)
    return Person.where('1 = 0') unless name.present?
    query = name.strip.split(' ')
    first, last = query[0].to_s + '%', query[1].to_s + '%'
    if last == '%'
      conditions = ['preferred_name ilike ? OR first_name ilike ? OR last_name ilike ?', first, first, first]
    else
      conditions = ['(preferred_name ilike ? OR first_name ilike ?) AND last_name ilike ?', first, first, last]
    end
    scope = scope.where(conditions)
    scope
  end

  def smart_merge(other)
    if user && other.user
      user.merge(other.user)
      self
    elsif other.user
      other.merge(self)
      other
    else
      merge(other)
      self
    end
  end

  def merge(other)
    reload
    Person.transaction do
      attributes.each do |k, v|
        next if k == ::Person.primary_key
        next if v == other.attributes[k]
        self[k] = case
                  when other.attributes[k].blank? then v
                  when v.blank? then other.attributes[k]
                  else
                    other_date = other.dateChanged || other.dateCreated
                    this_date = dateChanged || dateCreated
                    if other_date && this_date
                      other_date > this_date ? other.attributes[k] : v
                    else
                      v
                    end
                  end
      end

      # Phone Numbers
      phone_numbers.each do |pn|
        opn = other.phone_numbers.detect { |oa| oa.number == pn.number && oa.extension == pn.extension }
        pn.merge(opn) if opn
      end
      other.phone_numbers.each { |pn| pn.update_attribute(:person_id, id) unless pn.frozen? }

      # Email Addresses
      email_addresses.each do |pn|
        opn = other.email_addresses.detect { |oa| oa.email == pn.email }
        pn.merge(opn) if opn
      end
      emails = email_addresses.collect(&:email)
      other.email_addresses.each do |pn|
        if emails.include?(pn.email)
          pn.destroy
        else
          begin
            pn.update_attribute(:person_id, id) unless pn.frozen?
          rescue ActiveRecord::RecordNotUnique
            pn.destroy
          end
        end
      end

      # Addresses
      addresses.each do |address|
        addr = Address.find(address.id) # We need an Address object, not Fe::Address
        other_address = other.addresses.detect { |oa| oa.address_type == addr.address_type }
        addr.merge(other_address) if other_address
      end
      other.addresses do |address|
        other_address = addresses.detect { |oa| oa.addressType == address.addressType }
        address.update_attribute(:person_id, id) unless address.frozen? || other_address
      end

      # Summer Project Tool
      other.sp_applications.each { |ua| ua.update_attribute(:person_id, id) }         # update_all would be faster here, but if want callbacks & update_at field updated, then use use update(aka: update_attributes).

      SpProject.where(['pd_id = ? or apd_id = ? or opd_id = ? or coordinator_id = ?', other.id, other.id, other.id, other.id]).each do |ua|
        ua.update_attribute(:pd_id, id) if ua.pd_id == other.id
        ua.update_attribute(:apd_id, id) if ua.apd_id == other.id
        ua.update_attribute(:opd_id, id) if ua.opd_id == other.id
        ua.update_attribute(:coordinator_id, id) if ua.coordinator_id == other.id
      end

      if other.sp_user && sp_user
        sp_user.merge(other.sp_user)
      elsif other.sp_user
        SpUser.where(['person_id = ? or ssm_id = ? or created_by_id = ?', other.id, other.fk_ssmUserId, other.fk_ssmUserId]).each do |ua|
          ua.update_attribute(:person_id, id) if ua.person_id == other.id
          ua.update_attribute(:ssm_id, fk_ssmUserId) if ua.ssm_id == other.fk_ssmUserId
          ua.update_attribute(:created_by_id, fk_ssmUserId) if ua.created_by_id == other.fk_ssmUserId
        end
      end

      other.sp_staff.each { |ua| ua.update_attribute(:person_id, id) }
      other.sp_application_moves.each { |ua| ua.update_attribute(:moved_by_person_id, id) }

      other.sp_designation_numbers.each do |d|
        begin
          d.update_attribute(:person_id, id)
        rescue ActiveRecord::RecordNotUnique
        end
      end
      # end Summer Project Tool

      MergeAudit.create!(mergeable: self, merge_loser: other)
      other.reload
      GlobalRegistry::Entity.delete_or_ignore(other.global_registry_id) if other.global_registry_id
      other.destroy
      begin
        save(validate: false)
      rescue ActiveRecord::ReadOnlyRecord

      end
      self
    end
  end
end
