class DropRoleFromSpUser < ActiveRecord::Migration
  def self.up
    remove_column :sp_users, :role
  end

  def self.down
    add_column :sp_users, :role, :string
  end
end