require 'digest/md5'
require 'base64'

class User < ActiveRecord::Base
  self.table_name = 'simplesecuritymanager_user'
  self.primary_key = 'userID'

  # Relationships
  has_one :person, foreign_key: 'fk_ssmUserId'
  has_one :sp_user, foreign_key: 'ssm_id'
  has_many :authentications

  validates_uniqueness_of :username, case_sensitive: false, message: 'is already registered in our system.  This may have occurred when you registered for a Campus Crusade related conference; therefore, you do not need to create a new account. If you need help with your password, please click on the appropriate link at the login screen.  If you still need assistance, please send an email to help@campuscrusadeforchrist.com describing your problem.'

  def self.find_by_id(id)
    find_by_userID(id)
  end

  def self.find_or_create_from_cas(atts)
    # Look for a user with this guid
    guid = att_from_receipt(atts, 'ssoGuid')
    first_name = att_from_receipt(atts, 'firstName')
    last_name = att_from_receipt(atts, 'lastName')
    email = atts['username'] || atts['email']
    find_or_create_from_guid_or_email(guid, email, first_name, last_name)
  end

  def self.find_or_create_from_guid_or_email(guid, email, first_name, last_name, secure = true)
    if guid
      u = ::User.where('LOWER("globallyUniqueID") = ?', guid.downcase).first
    end

    # if we have a user by this method, great! update the email address if it doesn't match
    # We also need to make sure there isn't already another user with this email
    if u
      u.username = email if u.username != email && !User.find_by_username(email)
    else
      # If we didn't find a user with the guid, do it by email address and stamp the guid
      u = ::User.where('LOWER(username) = ?', email.try(:downcase)).first
      if u
        u.globallyUniqueID = guid
      else
        # If we still don't have a user in SSM, we need to create one.
        u = ::User.create!(username: email, globallyUniqueID: guid)
      end
    end
    # Update the password to match their gcx password too. This will save a round-trip later
    u.save(validate: false) if secure

    # make sure we have a person
    unless u.person
      # Attach the found person to the user, or create a new person
      u.person = ::Person.create!(first_name: first_name,
                                  last_name: last_name)
      u.person.fk_ssmUserId = u.id

      # Create a current address record if we don't already have one.
      u.person.current_address ||= ::CurrentAddress.create!(id: u.person.id, email: email)
      u.person.save(validate: false)
    end
    u
  end

  def apply_omniauth(omniauth)
    if username.blank?
      self.username = omniauth['info']['email']
      self.username = "#{omniauth['uid']}@#{omniauth[:provider]}" unless username.present?
    end
    unless Authentication.find_by(provider: omniauth['provider'], uid: omniauth['uid'])
      authentication = authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
      authentication.token = omniauth['credentials']['token'] if omniauth['credentials']
      authentication.save!
    end
  end

  def stamp_last_login
    self.lastLogin = Time.now
    save!
  end

  # A generic method for stamping a user has logged into a tool
  def stamp_column(column)
    if person = self.person
      person[column] = Time.new.to_s
      person.save!
    end
  end

  def create_person_and_address(person_attributes = {})
    unless person
      new_hash = { dateCreated: Time.now, dateChanged: Time.now,
                   createdBy: ApplicationController.application_name,
                   changedBy: ApplicationController.application_name }
      person = Person.new(person_attributes.merge(new_hash))
      person.user = self
      person.save!
      address = Address.new(created_by: ApplicationController.application_name,
                            changed_by: ApplicationController.application_name,
                            email: username,
                            address_type: 'current')
      address.person = person
      address.save!
    end
    person
  end

  def create_person_from_omniauth(omniauth)
    unless person
      new_hash = { dateCreated: Time.now, dateChanged: Time.now,
                   createdBy: ApplicationController.application_name,
                   changedBy: ApplicationController.application_name }
      person = Person.new(new_hash.merge(first_name: omniauth['first_name'], last_name: omniauth['last_name']))
      person.user = self
      person.save!
      address = Address.new(created_by: ApplicationController.application_name,
                            changed_by: ApplicationController.application_name,
                            email: username,
                            address_type: 'current')
      address.person = person
      address.save!
    end
    person
  end

  def self.create_new_user_from_cas(username, cas_extra_attributes)
    # Look for a user with this guid
    guid = cas_extra_attributes['ssoGuid']
    first_name = cas_extra_attributes['firstName']
    last_name = cas_extra_attributes['lastName']
    u = User.where(globallyUniqueID: guid).first
    # if we have a user by this method, great! update the email address if it doesn't match
    if u
      u.username = username
    else
      # If we didn't find a user with the guid, do it by email address and stamp the guid
      u = User.where(['username = ?', username]).first
      if u
        u.globallyUniqueID = guid
      else
        # If we still don't have a user in SSM, we need to create one.
        u = User.new(username: username.downcase, globallyUniqueID: guid)
      end
    end
    # Update the password to match their gcx password too. This will save a round-trip later
    u.save(validate: false)
    # make sure we have a person
    unless u.person
      u.create_person_and_address(first_name: first_name, last_name: last_name)
    end
    u
  end

  def merge(other)
    User.transaction do
      if !other.globallyUniqueID.blank? && globallyUniqueID.blank?
        self.globallyUniqueID = other.globallyUniqueID
        other.globallyUniqueID = nil
      end

      person.merge(other.person) if person && other.person

      # Authentications
      other.authentications.collect { |oa| oa.update_attribute(:user_id, id) }

      begin
        other.needs_merge = nil
        other.save(validate: false)
        self.needs_merge = nil
        save(validate: false)
      rescue ActiveRecord::ReadOnlyRecord

      end
    end

    MergeAudit.create!(mergeable: self, merge_loser: other)
    other.reload
    other.destroy
  end

  protected

  # not sure why but cas sometimes sends the extra attributes as underscored
  def self.att_from_receipt(atts, key)
    atts[key] || atts[key.underscore]
  end
end
