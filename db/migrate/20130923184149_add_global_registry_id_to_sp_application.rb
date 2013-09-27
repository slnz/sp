class AddGlobalRegistryIdToSpApplication < ActiveRecord::Migration
  def self.up
    add_column :sp_applications, :global_registry_id, :bigint
    add_index :sp_applications, :global_registry_id
  end

  def self.down
    remove_column :sp_applications, :global_registry_id
  end
end
