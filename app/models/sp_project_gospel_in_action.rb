require_dependency 'global_registry_methods'

class SpProjectGospelInAction < ActiveRecord::Base
  include GlobalRegistryMethods
  include Sidekiq::Worker

  belongs_to :gospel_in_action, :class_name => "SpGospelInAction", :foreign_key => "gospel_in_action_id"
  belongs_to :project, :class_name => "SpProject", :foreign_key => "project_id"

  def async_push_to_global_registry
    attributes_to_push['project_id'] = project.global_registry_id if project && project.global_registry_id
    attributes_to_push['gospel_in_action_id'] = gospel_in_action.global_registry_id if gospel_in_action && gospel_in_action.global_registry_id

    super
  end

  def self.skip_fields_for_gr
    %w[id created_at updated_at global_registry_id]
  end

  def self.global_registry_entity_type_name
    'summer_project_project_gospel_in_action'
  end
end
