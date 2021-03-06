module Fe
  class Payment < ActiveRecord::Base
    include CruLib::GlobalRegistryMethods
    include Sidekiq::Worker

    attr_accessor :first_name, :last_name, :address, :city, :state, :zip, :card_number, :encrypted_card_number,
                  :expiration_month, :expiration_year, :encrypted_security_code, :staff_first, :staff_last, :card_type

    belongs_to :application, class_name: 'SpApplication', foreign_key: 'application_id'

    scope :non_denied, -> { where("status <> 'Denied' OR status is null") }

    after_save :check_app_complete

    validate :credit_card_validation
    validate :staff_email_present_if_staff_payment

    def credit_card_validation
      if credit?
        errors.add_on_empty([:first_name, :last_name, :address, :city, :state, :zip, :card_number,
                             :expiration_month, :expiration_year])
        errors.add(:security_code, "can't be blank.") if encrypted_security_code.blank?
      end
    end

    def staff_email_present_if_staff_payment
      if staff? && !payment_account_no.include?('/') # Don't try to validate chart fields
        staff = ::Person.find_by(account_no: payment_account_no)
        unless staff
          errors.add(:base, "We couldn't find a staff member with that account number")
          return false
        end

        unless staff.email.present?
          errors.add(:base, "The staff member you've picked doesn't have an address on file for us to send the request to.")
        end
      end
    end

    def to_s
      "#{payment_type}: #{amount} on #{created_at}"
    end

    def check_app_complete
      if self.approved?
        application.complete
      end
    end

    def credit?
      payment_type == 'Credit Card'
    end

    def staff?
      payment_type == 'Staff'
    end

    def approved?
      status == 'Approved'
    end

    def approve!
      self.status = 'Approved'
      self.auth_code ||= card_number[-4..-1] if card_number.present?
      self.save!
    end

    def async_push_to_global_registry
      return unless application

      application.async_push_to_global_registry unless application.global_registry_id.present?

      super(application.global_registry_id, 'summer_project_application', application)
    end

    def self.push_structure_to_global_registry
      parent_id = GlobalRegistry::EntityType.get(
          'filters[name]' => 'summer_project_application'
      )['entity_types'].first['id']
      super(parent_id)
    end

    def self.global_registry_entity_type_name
      'summer_project_payment'
    end
  end
end
