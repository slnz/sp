class AddIsStaffToSpReference < ActiveRecord::Migration
  def self.up
    add_column :sp_references, :is_staff, :boolean, :default => false, :nil => false
  end

  def self.down
    remove_column :sp_references, :is_staff
  end
end
