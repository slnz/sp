class AddGlobalRegistryIdToAddress < ActiveRecord::Migration
  def change
    add_column :ministry_newaddress, :global_registry_id, :string, limit: 40
  end
end
