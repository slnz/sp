class ChangeRefHomePhoneToPhone < ActiveRecord::Migration
  def self.up
    rename_column :sp_references, :home_phone, :phone
  end

  def self.down
    rename_column :sp_references, :phone, :home_phone
  end
end