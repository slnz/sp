require_dependency 'cru_enhancements'
class AddressSerializer < ActiveModel::Serializer
  include CruEnhancements

  attributes :id, :address1, :address2, :address3, :address4, :city, :state, :zip, :country, :created_at, :updated_at
end
