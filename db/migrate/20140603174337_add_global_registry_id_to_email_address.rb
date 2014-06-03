class AddGlobalRegistryIdToEmailAddress < ActiveRecord::Migration
  def change
    add_column :email_addresses, :global_registry_id, :string, length: 36
    add_column :phone_numbers, :global_registry_id, :string, length: 36
  end
end
