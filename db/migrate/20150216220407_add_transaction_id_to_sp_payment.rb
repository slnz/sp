class AddTransactionIdToSpPayment < ActiveRecord::Migration
  def change
    add_column :sp_payments, :transaction_id, :string
  end
end
