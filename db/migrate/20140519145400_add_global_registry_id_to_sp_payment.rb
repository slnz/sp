class AddGlobalRegistryIdToSpPayment < ActiveRecord::Migration
  def change
    add_column :sp_payments, :global_registry_id, :string, limit: 40
  end
end
