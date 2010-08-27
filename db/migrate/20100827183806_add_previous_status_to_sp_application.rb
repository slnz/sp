class AddPreviousStatusToSpApplication < ActiveRecord::Migration
  def self.up
    add_column :sp_applications, :previous_status, :string
  end

  def self.down
    remove_column :sp_applications, :previous_status
  end
end
