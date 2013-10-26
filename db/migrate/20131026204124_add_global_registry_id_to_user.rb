class AddGlobalRegistryIdToUser < ActiveRecord::Migration
  def change
    add_column :simplesecuritymanager_user, :global_registry_id, :bigint
    add_index :simplesecuritymanager_user, :global_registry_id
  end
end
