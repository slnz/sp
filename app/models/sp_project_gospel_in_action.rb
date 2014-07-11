class SpProjectGospelInAction < ActiveRecord::Base
  include Sidekiq::Worker
  include CruLib::GlobalRegistryRelationshipMethods

  belongs_to :gospel_in_action, :class_name => "SpGospelInAction", :foreign_key => "gospel_in_action_id"
  belongs_to :project, :class_name => "SpProject", :foreign_key => "project_id"

  def async_push_to_global_registry
    return unless project && gospel_in_action
    super
  end

  def attributes_to_push
    if global_registry_id
      super
    else
      super('gospel_in_action', 'summer_project_gospel_in_action', gospel_in_action)
    end
  end

  def create_in_global_registry(base_object = nil, relationship_name = nil)
    super(project, 'gospel_in_action')
  end


  def self.push_structure_to_global_registry
    super(SpProject, SpGospelInAction, 'project', 'gospel_in_action')
  end

  def self.skip_fields_for_gr
    %w[id created_at updated_at project_id gospel_in_action_id global_registry_id]
  end
end
