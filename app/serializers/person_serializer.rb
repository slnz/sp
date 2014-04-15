require_dependency 'cru_enhancements'
class PersonSerializer < ActiveModel::Serializer
  INCLUDES = [:phone_numbers, :email_addresses]
  include CruEnhancements

  attributes :id, :account_no, :last_name, :first_name, :middle_name, :preferred_name, :gender, :region,
             :is_staff, :title, :campus, :university_state, :year_in_school, :major, :minor,
             :marital_status, :is_child, :created_at, :updated_at, :created_by, :changed_by,
             :birth_date, :date_became_christian, :graduation_date, :is_secure,
             :ministry, :strategy, :fb_uid, :global_registry_id, :user_id

  has_one :address

  def address
    object.current_address
  end

  def is_staff
    object.isStaff?
  end

  def is_secure
    object.isSecure == 'T'
  end
end
