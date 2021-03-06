class SpWorldRegion < ActiveRecord::Base
  include CruLib::GlobalRegistryMethods
  include Sidekiq::Worker

  def self.skip_fields_for_gr
    %w(id created_at updated_at global_registry_id)
  end

  def self.global_registry_entity_type_name
    'summer_project_world_region'
  end
end
