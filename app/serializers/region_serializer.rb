require_dependency 'cru_enhancements'

class RegionSerializer < ActiveModel::Serializer
  attributes :id, :name, :abbrv, :address1, :address2, :city, :state, :zip, :phone, :fax, :email, :url
end
