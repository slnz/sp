require_dependency 'global_registry_methods'

class SpStudentQuote < ActiveRecord::Base
  include GlobalRegistryMethods
  include Sidekiq::Worker

  belongs_to :project, :class_name => "SpProject", :foreign_key => "project_id"

  after_save :push_to_global_registry

  def push_to_global_registry
    super(project.global_registry_id)
  end

  def self.skip_fields_for_gr
    %w[id created_at updated_at project_id global_registry_id]
  end

  def self.global_registry_entity_type_name
    'summer_project_student_quote'
  end
end
