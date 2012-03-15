class AddAccountBalanceToSpDesignationNumbers < ActiveRecord::Migration
  def self.up
    add_column :sp_designation_numbers, :account_balance, :integer, :default => 0, :after => :designation_number
  end

  def self.down
    remove_column :sp_designation_numbers, :account_balance
  end
end
