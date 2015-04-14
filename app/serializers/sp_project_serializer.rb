require_dependency 'cru_enhancements'

class SpProjectSerializer < ActiveModel::Serializer
  include CruEnhancements

  attributes :id, :name, :primary_partner, :secondary_partner, :partner_region_only, :city, :country, :world_region,
             :display_location, :description, :picture_url

  has_one :pd
  has_one :apd
  has_one :opd
  has_one :coordinator
  has_many :staff
  has_many :volunteers
  has_many :applicants

  delegate :picture_url, to: :object
end
