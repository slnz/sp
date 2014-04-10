require_dependency 'cru_enhancements'
class UserSerializer < ActiveModel::Serializer
  INCLUDES = [:authentications]
  include CruEnhancements

  attributes :id, :username, :created_at, :updated_at
end
