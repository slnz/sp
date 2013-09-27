class AddGlobalRegistryIdToSpTables < ActiveRecord::Migration
  def self.up
    add_column :sp_staff, :global_registry_id, :bigint
    add_column :sp_ministry_focuses, :global_registry_id, :bigint
    add_column :sp_gospel_in_actions, :global_registry_id, :bigint
    add_column :sp_project_gospel_in_actions, :global_registry_id, :bigint
    add_column :sp_stats, :global_registry_id, :bigint
    add_column :sp_student_quotes, :global_registry_id, :bigint
    add_column :sp_users, :global_registry_id, :bigint
    add_column :sp_world_regions, :global_registry_id, :bigint
  end

  def self.down
    remove_column :sp_staff, :global_registry_id
    remove_column :sp_ministry_focuses, :global_registry_id
    remove_column :sp_gospel_in_actions, :global_registry_id
    remove_column :sp_project_gospel_in_actions, :global_registry_id
    remove_column :sp_stats, :global_registry_id
    remove_column :sp_student_quotes, :global_registry_id
    remove_column :sp_users, :global_registry_id
    remove_column :sp_world_regions, :global_registry_id
  end
end
