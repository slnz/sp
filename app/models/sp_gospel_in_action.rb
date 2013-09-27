require_dependency 'global_registry_methods'

class SpGospelInAction < ActiveRecord::Base
  include Sidekiq::Worker
  include GlobalRegistryMethods

  has_many :project_gospel_in_actions, :class_name => "SpProjectGospelInAction", :foreign_key => "sp_gospel_in_action_id"
  default_scope order(:name)

  def self.skip_fields_for_gr
    %w[id created_at updated_at global_registry_id]
  end

  def self.global_registry_entity_type_name
    'summer_project_gospel_in_action'
  end

end
