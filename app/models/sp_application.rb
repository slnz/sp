require 'aasm'

require 'digest/md5'
class SpApplication < Fe::Application
  # include Fe::AnswerSheetConcern
  include CruLib::GlobalRegistryRelationshipMethods
  include Sidekiq::Worker
  include AASM

  STELLENT_ROLE = 'studentContributor'

  COST = 25

  before_create :create_answer_sheet_question_sheet
  has_many :payments, foreign_key: 'application_id', class_name: 'Fe::Payment'

  sidekiq_options unique: true

  aasm initial: :started, column: :status do
    # State machine stuff
    state :started
    state :submitted, enter: proc { |app|
      Fe::Notifier.notification(
          app.email, # RECIPIENTS
          Fe.from_email, # FROM
          'Application Submitted'
      ).deliver if app.email.present? # LIQUID TEMPLATE NAME
      app.submitted_at = Time.now
      app.previous_status = app.status
    }

    state :ready, enter: proc { |app|
      app.completed_at ||= Time.now
      Fe::Notifier.notification(
          app.email, # RECIPIENTS
          Fe.from_email, # FROM
          'Application Completed'
      ).deliver if app.email.present?
      app.previous_status = app.status
    }

    state :unsubmitted, enter: proc { |app|
      Fe::Notifier.notification(
          app.email, # RECIPIENTS
          Fe.from_email, # FROM
          'Application Unsubmitted'
      ).deliver if app.email.present?
      app.previous_status = app.status
    }

    state :withdrawn, enter: proc { |app|
      Fe::Notifier.notification(
          app.email, # RECIPIENTS
          Fe.from_email, # FROM
          'Application Withdrawn'
      ).deliver if app.email.present?
      app.withdrawn_at = Time.now
      app.previous_status = app.status
    }

    state :accepted_as_student_staff, enter: proc { |app|
      app.accept
    }

    state :accepted_as_participant, enter: proc { |app|
      app.accept
    }

    state :declined, enter: proc { |app|
      app.previous_status = app.status
    }

    event :submit do
      transitions to: :submitted, from: :started
      transitions to: :submitted, from: :unsubmitted
      transitions to: :submitted, from: :withdrawn
      transitions to: :submitted, from: :ready
      # Handle when user clicks to edit references, then clicks submit
      transitions to: :submitted, from: :submitted
    end

    event :withdraw do
      transitions to: :withdrawn, from: :started
      transitions to: :withdrawn, from: :submitted
      transitions to: :withdrawn, from: :ready
      transitions to: :withdrawn, from: :unsubmitted
      transitions to: :withdrawn, from: :declined
      transitions to: :withdrawn, from: :accepted_as_student_staff
      transitions to: :withdrawn, from: :accepted_as_participant
    end

    event :unsubmit do
      transitions to: :unsubmitted, from: :submitted
      transitions to: :unsubmitted, from: :withdrawn
      transitions to: :unsubmitted, from: :ready
    end

    event :complete do
      transitions to: :ready, from: :submitted, guard: :has_paid?
      transitions to: :ready, from: :unsubmitted, guard: :has_paid?
      transitions to: :ready, from: :started, guard: :has_paid?
      transitions to: :ready, from: :withdrawn, guard: :has_paid?
      transitions to: :ready, from: :declined, guard: :has_paid?
      transitions to: :ready, from: :accepted_as_student_staff, guard: :has_paid?
      transitions to: :ready, from: :accepted_as_participant, guard: :has_paid?
    end

    event :accept_as_student_staff do
      transitions to: :accepted_as_student_staff, from: :ready, guard: :has_paid?
      transitions to: :accepted_as_student_staff, from: :started, guard: :has_paid?
      transitions to: :accepted_as_student_staff, from: :withdrawn, guard: :has_paid?
      transitions to: :accepted_as_student_staff, from: :declined, guard: :has_paid?
      transitions to: :accepted_as_student_staff, from: :submitted, guard: :has_paid?
      transitions to: :accepted_as_student_staff, from: :accepted_as_participant, guard: :has_paid?
    end

    event :accept_as_participant do
      transitions to: :accepted_as_participant, from: :ready, guard: :has_paid?
      transitions to: :accepted_as_participant, from: :started, guard: :has_paid?
      transitions to: :accepted_as_participant, from: :withdrawn, guard: :has_paid?
      transitions to: :accepted_as_participant, from: :declined, guard: :has_paid?
      transitions to: :accepted_as_participant, from: :submitted, guard: :has_paid?
      transitions to: :accepted_as_participant, from: :accepted_as_student_staff, guard: :has_paid?
    end

    event :decline do
      transitions to: :declined, from: :started
      transitions to: :declined, from: :submitted
      transitions to: :declined, from: :ready
      transitions to: :declined, from: :accepted_as_student_staff
      transitions to: :declined, from: :accepted_as_participant
    end
  end

  belongs_to :person, class_name: '::Person'
  alias_method :applicant, :person # Fe expects applicant

  belongs_to :project, class_name: 'SpProject', foreign_key: :project_id

  belongs_to :preference1, class_name: 'SpProject', foreign_key: :preference1_id
  belongs_to :preference2, class_name: 'SpProject', foreign_key: :preference2_id
  belongs_to :preference3, class_name: 'SpProject', foreign_key: :preference3_id
  belongs_to :preference4, class_name: 'SpProject', foreign_key: :preference4_id
  belongs_to :preference5, class_name: 'SpProject', foreign_key: :preference5_id
  belongs_to :current_project_queue, class_name: 'SpProject', foreign_key: :current_project_queue_id
  has_one :evaluation, class_name: 'SpEvaluation', foreign_key: :application_id

  scope :for_year, proc { |year| where(year: year) }
  scope :preferrenced_project, proc { |project_id| where(['project_id = ? OR preference1_id = ? OR preference2_id = ? OR preference3_id = ?', project_id, project_id, project_id, project_id]) }

  scope :preferred_project, proc { |project_id|
    { conditions: ['project_id = ?', project_id],
      include: :person }
  }
  scope :not_staff, -> { where("ministry_person.\"isStaff\" <> 't' OR ministry_person.\"isStaff\" Is Null").joins(:person).references(:person) }
  before_create :set_su_code
  after_save :unsubmit_on_project_change, :complete, :send_acceptance_email, :log_changed_project, :update_project_counts

  def next_states_for_events
    self.class.aasm.events.values.select { |event| event.transitions_from_state?(status.to_sym) && send(('may_' + event.name.to_s + '?').to_sym) }.collect do
        |e| [e.transitions_from_state(status.to_sym).first.to.to_s.humanize, e.name]
    end
  end

  def designation_number=(val)
    if designation = SpDesignationNumber.where(person_id: person_id, project_id: project_id, year: SpApplication.year).first
      designation.designation_number = val
    else
      designation = SpDesignationNumber.new(
          person_id: person_id,
          project_id: project_id,
          designation_number: val,
          year: SpApplication.year)
    end
    designation.save!
  end

  def designation_number(year = SpApplication.year)
    if designation = SpDesignationNumber.where(person_id: person_id, project_id: project_id, year: year).first
      designation.designation_number.to_s
    else
      nil
    end
  end

  def donations
    SpDonation.where(designation_number: SpDesignationNumber.where(person_id: person_id, project_id: project_id).collect(&:designation_number))
  end

  def accept
    self.accepted_at = Time.now
    self.previous_status = status
    async(:create_relay_account_if_needed)
  end

  def set_up_give_site
    designation = get_designation_number
    return if is_secure?
    return unless designation
    return if has_give_site?

    create_relay_account_if_needed
    set_designation_number_in_relay
    set_role_in_ldap
    client = StellentClient.new
    client.push_to_stellent(self)

    Fe::Notifier.notification(person.email_address, # RECIPIENTS
                              Fe.from_email, # FROM
                              'Giving site created', # LIQUID TEMPLATE NAME
                              'first_name' => person.nickname,
                              'site_url' => "#{APP_CONFIG['spgive_url']}/#{designation}",
                              'username' => person.user.username,
                              'password' => person.user.password_plain).deliver

    update_column(:has_give_site, true)
  end

  def create_relay_account_if_needed
    return if Rails.env.test? # TODO figure out how to properly test this

    unless person.user.globallyUniqueID.present?
      password = SecureRandom.hex(5) + 'a'
      person.user.password_plain = password
      person.user.globallyUniqueID = RelayApiClient::Base.create_account(person.email_address.strip, password, person.nickname, person.last_name)
      begin
        person.user.save(validate: false)
      rescue ActiveRecord::RecordNotUnique
        # This means we have a duplicate person that we need to merge
        other_user = User.where(globallyUniqueID: person.user.globallyUniqueID).first
        this_user = User.find(person.user.id)
        this_user.merge(other_user)
        person.reload
      end
    end

    # make sure we have the right username
    l = IdentityLinker::Linker.find_linked_identity('ssoguid', person.user.globallyUniqueID, 'relay_username')
    username = l[:identity][:id_value]
    if username != person.user.username
      person.user.username = username
      person.user.save
    end
  end

  def set_designation_number_in_relay
    return if Rails.env.test? # TODO set up web mocks for testing

    designation_number = get_designation_number
    return unless designation_number.present? && person.user.globallyUniqueID.present?

    unless RelayApiClient::Base.set_designation_number(person.user.globallyUniqueID, designation_number)
      fail 'failed to set designation number in relay'
    end
  end

  def set_role_in_ldap
    return if Rails.env.test? # TODO set up web mocks for testing

    unless RelayApiClient::Base.set_role(ssoguid: person.user.globallyUniqueID,
                                         role: STELLENT_ROLE,
                                         system_id: 'missions',
                                         system_password: APP_CONFIG['ldap_password'])
      fail 'failed to set role in ldap via relay'
    end
  end

  def validates
    if (status == 'accepted_as_student_staff' || status == 'accepted_as_participant') && project_id.nil?
      errors.add_to_base('You must specify which project you are accepting this applicant to.')
    end
  end

  # When changing this method, make sure the commit gets pulled into the MPD Tool as well
  def self.year
    Time.now.month >= 9 ? Time.now.year + 1 : Time.now.year
  end

  def self.deadline1
    Time.parse((SpApplication.year - 1).to_s + '/12/11 00:00:00 PST')
  end

  def self.deadline2
    Time.parse(SpApplication.year.to_s + '/01/25 00:00:00 PST')
  end

  def self.deadline3
    Time.parse(SpApplication.year.to_s + '/02/25 00:00:00 PST')
  end

  def name
    person.try(:informal_full_name)
  end

  def phone
    person.try(:current_address).try(:homePhone)
  end

  def deadline_met
    if completed_at
      if completed_at < SpApplication.deadline1 + 1.day
        return 1
      end
      if completed_at < SpApplication.deadline2 + 1.day
        return 2
      end
      if completed_at < SpApplication.deadline3 + 1.day
        return 3
      end
    end
    0
  end

  def project_cost
    project.student_cost if project
  end

  def is_secure?
    project.secure?
  end

  # Get project_id (project_id | preference1_id | preference2_id | preference3_id | preference4_id | preference5_id)
  def get_project_id
    unless project_id = self.project_id
      if preference5_id
        project_id = preference5_id
      elsif preference4_id
        project_id = preference4_id
      elsif preference3_id
        project_id = preference3_id
      elsif preference2_id
        project_id = preference2_id
      elsif preference1_id
        project_id = preference1_id
      end
    end
    project_id
  end

  # Get designation_number
  def get_designation_number(year = SpApplication.year)
    SpDesignationNumber.find_by_person_id_and_project_id_and_year(person_id, get_project_id, year).try(:designation_number)
  end

  # The statuses that mean an application has NOT been submitted
  def self.unsubmitted_statuses
    %w(started unsubmitted)
  end

  # The statuses that mean an applicant is NOT ready to evaluate
  def self.not_ready_statuses
    %w(submitted)
  end

  # The statuses that mean an applicant is NOT going
  def self.not_going_statuses
    %w(withdrawn declined)
  end

  # The statuses that mean an applicant IS ready to evaluate
  def self.ready_statuses
    %w(ready)
  end

  def self.accepted_statuses
    %w(accepted_as_student_staff accepted_as_participant)
  end

  def self.applied_statuses
    SpApplication.ready_statuses | SpApplication.accepted_statuses
  end

  # The statuses that mean an applicant's application is not ready, but still in progress
  def self.uncompleted_statuses
    %w(started submitted unsubmitted)
  end

  def self.statuses
    SpApplication.unsubmitted_statuses | SpApplication.not_ready_statuses | SpApplication.ready_statuses | SpApplication.accepted_statuses | SpApplication.not_going_statuses
  end

  scope :ascend_by_accepted, -> { order('sp_applications.accepted_at') }
  scope :descend_by_accepted, -> { order('sp_applications.accepted_at desc') }
  scope :ascend_by_ready, -> { order('sp_applications.completed_at') }
  scope :descend_by_ready, -> { order('sp_applications.completed_at desc') }
  scope :ascend_by_submitted, -> { order('sp_applications.submitted_at') }
  scope :descend_by_submitted, -> { order('sp_applications.submitted_at desc') }
  scope :ascend_by_started, -> { order('sp_applications.created_at') }
  scope :descend_by_started, -> { order('sp_applications.created_at desc') }
  scope :ascend_by_name, -> { joins(:person).order('last_name, first_name') }
  scope :descend_by_name, -> { joins(:person).order('last_name desc, first_name desc') }
  scope :accepted, -> { where('sp_applications.status' => SpApplication.accepted_statuses) }
  scope :accepted_participants, -> { where('sp_applications.status' => 'accepted_as_participant') }
  scope :accepted_student_staff, -> { where('sp_applications.status' => 'accepted_as_student_staff') }
  scope :ready_to_evaluate, -> { where('sp_applications.status' => SpApplication.ready_statuses) }
  scope :submitted, -> { where('sp_applications.status' => SpApplication.not_ready_statuses) }
  scope :not_submitted, -> { where('sp_applications.status' => SpApplication.unsubmitted_statuses) }
  scope :not_going, -> { where('sp_applications.status' => SpApplication.not_going_statuses) }
  scope :applicant, -> { where('sp_applications.status' => SpApplication.applied_statuses) }

  scope :male, -> { where("ministry_person.gender = '1'").joins(:person) }
  scope :female, -> { where("ministry_person.gender <> '1'").joins(:person) }

  delegate :campus, to: :person

  def self.payment_deadline
    Time.parse("#{SpApplication.year}-02-25 03:00")
  end

  def has_paid?
    return true if payments.detect(&:approved?)
    return true unless question_sheets.collect(&:questions).flatten.detect { |q| q.is_a?(Fe::PaymentQuestion) && q.required? }
    false
  end

  def accepted?
    SpApplication.accepted_statuses.include?(status)
  end

  def paid_at
    payments.each do |payment|
      return payment.updated_at if payment.approved?
    end
    nil
  end

  def waive_fee!
    payments.create!(status: 'Approved', payment_type: 'Waived')
    complete # Check to see if application is complete
  end

  def self.questionnaire
    @@questionnaire ||= Questionnaire.find_by_id(1, include: :pages, order: 'sp_questionnaire_pages.position')
  end

  def complete(ref = nil)
    return false unless self.submitted?
    # Make sure all required references are completed
    references.each do |reference|
      if reference.required?
        return false unless reference.completed? || reference == ref
      end
    end
    return false unless self.has_paid?
    self.complete!
  end

  def set_su_code
    self.su_code = Digest::MD5.hexdigest((object_id + Time.now.to_i).to_s)
  end

  # The :frozen? method lets the form engine know to not allow
  # the user to change the answer to a question.
  def frozen?
    return @frozen unless @frozen.nil?
    @frozen = !%w(started unsubmitted).include?(status) &&
              !Thread.current[:user].try(:sp_user).try(:can_su_application?)
  end

  def can_change_references?
    %w(started unsubmitted submitted).include?(status)
  end

  def available_date
    @available_date ||= get_answer(53)
  end

  def available_date=(val)
    save_answer(53, val)
  end

  def return_date
    @return_date ||= get_answer(54)
  end

  def return_date=(val)
    save_answer(54, val)
  end

  def check_email_frequency
    @check_email_frequency ||= get_answer(33)
  end

  def communication_preference
    @communication_preference ||= get_answer(34)
  end

  def health_insurance
    @health_insurance ||= get_answer(248)
  end

  def insurance_provider
    @insurance_provider ||= get_answer(249)
  end

  def insurance_policy_number
    @insurance_policy_number ||= get_answer(250)
  end

  def continuing_school?
    @continuing_school ||= is_true(get_answer(57)) ? 'Yes' : 'No'
  end

  def has_passport?
    @has_passport ||= is_true(get_answer(409)) ? 'Yes' : 'No'
  end

  def activities_on_campus
    @activities_on_campus ||= Element.find(65)
  end

  def ministries_on_campus
    @ministries_on_campus ||= Element.find(68)
  end

  def applying_for_internship
    @applying_for_internship ||= Element.find(98)
  end

  def willing_for_other_projects
    @willing_for_other_projects ||= Element.find(88)
  end

  def start_date
    result = read_attribute(:start_date)
    if result.blank? && project
      result = project.start_date
    end
    result
  end

  def end_date
    result = read_attribute(:end_date)
    if result.blank? && project
      result = project.end_date
    end
    result
  end

  def start_date=(date)
    if project.start_date != date
      write_attribute(:start_date, date)
    elsif date == project.start_date
      write_attribute(:start_date, nil)
    end
  end

  def end_date=(date)
    if project.end_date != date
      write_attribute(:end_date, date)
    elsif date == project.end_date
      write_attribute(:end_date, nil)
    end
  end

  def willing_for_other_projects_answer
    is_true(get_answer(88))
  end

  def willing_for_other_projects_answer=(val)
    save_answer(88, val)
  end

  def is_true(val)
    [1, '1', true, 'true'].include?(val)
  end

  def get_answer(q_id)
    answer = get_answer_object(q_id)
    answer ? answer.answer.to_s : ''
  end

  def save_answer(q_id, val)
    answer = get_answer_object(q_id)
    if answer
      answer.answer = val
      answer.save!
    end
  end

  def get_answer_object(q_id)
    answers.detect { |a| a.question_id == q_id }
  end

  def log_changed_project
    if changed.include?('project_id') && changes['project_id'].all?(&:present?)
      current_person = Thread.current[:user].try(:person) || Person.new
      old_project = SpProject.find(changes['project_id'].first)
      new_project = SpProject.find(changes['project_id'].last)
      SpApplicationMove.create!(application_id: id, old_project_id: old_project.id, new_project_id: new_project.id,
                                moved_by_person_id: current_person.id)

      # Move designation number
      dn = SpDesignationNumber.where(person_id: person_id, project_id: old_project.id, year: year).first
      dn.update_attribute(:project_id, new_project.id) if dn
      designation_number = dn.present? ? dn.designation_number : nil

      # Notify old and new directors
      old_pds = [old_project.pd, old_project.apd, old_project.opd]
      new_pds = [new_project.pd, new_project.apd, new_project.opd]
      recipients = old_pds.compact.empty? ? ['summer.missions@cru.org'] : old_pds.compact.collect(&:email)
      recipients += new_pds.compact.empty? ? ['summer.missions@cru.org'] : new_pds.compact.collect(&:email)
      Fe::Notifier.notification(recipients.compact, # RECIPIENTS
                                Fe.from_email, # FROM
                                'Application Moved', # LIQUID TEMPLATE NAME
                                'applicant_name' => name,
                                'moved_by' => current_person.informal_full_name,
                                'original_project' => old_project.name,
                                'new_project' => new_project.name).deliver

      if designation_number.present?
        recipient = 'summerprojectdonations@cru.org'
        Fe::Notifier.notification(recipient, # RECIPIENTS
                                  Fe.from_email, # FROM
                                  'Application Moved - Donation Services', # LIQUID TEMPLATE NAME
                                  'applicant_name' => name,
                                  'designation_number' => designation_number,
                                  'original_project' => old_project.name,
                                  'original_chartfield' => old_project.scholarship_chartfield,
                                  'new_project' => new_project.name,
                                  'new_chartfield' => new_project.scholarship_chartfield).deliver
        regenerate_give_site
      end

      # Update project counts
      old_project.update_counts(person)
      new_project.update_counts(person)
    end
  end

  def regenerate_give_site
    update_column(:has_give_site, false)
    async(:set_up_give_site)
  end

  # When an applicant status changes, we need to update the project counts
  def update_project_counts
    if changed.include?('status')
      project.update_counts(person) if project
    end
  end

  # This method removes the applicant from their project queue and
  # project assignment (decrementing counts appropriately).
  def remove_from_project_assignment
    if project
      project.current_students_men -= 1 if person.is_male?
      project.current_students_women -= 1 unless person.is_male?
      project.save(validate: false)
    end
    project
  end

  def email_address
    person.current_address.email if person && person.current_address
  end

  alias_method :email, :email_address

  def account_balance
    designation_no = get_designation_number
    SpDonation.get_balance(designation_no, year)
  end

  def self.send_status_emails
    logger.info('Sending application reminder emails')
    uncompleted_apps = SpApplication.select('app.*')
                       .where(['app.status in (?) and app.year = ? and proj.start_date > ?', SpApplication.uncompleted_statuses, SpApplication.year, Time.now])
                       .joins('as app inner join sp_projects as proj on (proj.id = app.preference1_id)')
    uncompleted_apps.each do |app|
      if app.person.informal_full_name && app.email_address && app.email_address != ''
        SpApplicationMailer.deliver_status(app)
      end
    end
  end

  def send_acceptance_email
    if changed.include?('applicant_notified') and applicant_notified? && status.starts_with?('accept')
      Fe::Notifier.notification(email_address, # RECIPIENTS
                                Fe.from_email, # FROM
                                'Application Accepted', # LIQUID TEMPLATE NAME
                                'project_name' => project.try(:name)).deliver
    end
  end

  def unsubmit_on_project_change
    if changed.include?('project_id')
      # If the new project uses a different template or has additional questions, we need to unsubmit
      if changes['project_id'].length == 2 && changes.all?(&:present?)
        old_project, new_project = SpProject.find_by_id(changes['project_id'][0]), SpProject.find_by_id(changes['project_id'][1])
        if old_project && new_project
          if old_project.basic_info_question_sheet != new_project.basic_info_question_sheet ||
             old_project.template_question_sheet != new_project.template_question_sheet ||
             (new_project.project_specific_question_sheet && new_project.project_specific_question_sheet.questions.present?)
            if submitted? || ready? || withdrawn?
              unsubmit!
            end
            clean_up_unneeded_references
          end
        end
      end
    end
  end

  def clean_up_unneeded_references
    # Do any necessary cleanup of references to match new project's requirements
    if project
      logger.debug('has project')
      reference_questions = project.template_question_sheet.questions.select { |q| q.is_a?(Fe::ReferenceQuestion) }
      if references.length > reference_questions.length
        references.each do |reference|
          # See if this reference's question_id matches any of the questions for the new project
          if question = reference_questions.detect { |rq| rq.id == reference.question_id }
            logger.debug('matched question: ' + question.id.to_s)
            next
          end
          # If the question_id doesn't match, but the reference question is based on the same reference template (question sheet)
          # AND we don't already have a reference for that question
          # update the reference with the new question_id
          if (reference_question = reference_questions.detect { |rq| rq.related_question_sheet_id == reference.question.related_question_sheet_id }) &&
             !references.detect { |r| r.question_id == reference_question.id }
            reference.update_attribute(:question_id, reference_question.id)
            next
          end
          # If we get here, the reference isn't needed anymore on this application, so we should delete it.
          reference.destroy unless reference.completed? # no point in deleting a completed reference
        end
      end
    end
  end

  def async_push_to_global_registry
    return unless person && project

    person.async_push_to_global_registry unless person.global_registry_id.present?
    project.async_push_to_global_registry unless project.global_registry_id.present?
    super
  end

  def attributes_to_push(*args)
    if global_registry_id
      attributes_to_push = super
      attributes_to_push['preference1_id'] = preference1 ? preference1.global_registry_id : nil
      attributes_to_push['preference2_id'] = preference2 ? preference2.global_registry_id : nil
      attributes_to_push['preference3_id'] = preference3 ? preference3.global_registry_id : nil
      attributes_to_push['preference4_id'] = preference4 ? preference4.global_registry_id : nil
      attributes_to_push['preference5_id'] = preference5 ? preference5.global_registry_id : nil
      attributes_to_push.reject!(&:blank?)
      attributes_to_push
    else
      super(relationship_name: 'summer_project_application', related_name: 'summer_project', related_object: project, base_object: person)
    end
  end

  def create_in_global_registry(*_args)
    super(person, 'summer_project_application')
  end

  def create_answer_sheet_question_sheet
    self.answer_sheet_question_sheet ||= ::Fe::AnswerSheetQuestionSheet.create(question_sheet_id: 1) # TODO: NO CONSTANT
  end

  def self.push_structure_to_global_registry
    super(Person, SpProject, 'applicant', 'summer_project_application')
  end

  def self.skip_fields_for_gr
    super +
      %w(id old_id su_code account_balance current_project_queue_id person_id project_id)
  end
end
