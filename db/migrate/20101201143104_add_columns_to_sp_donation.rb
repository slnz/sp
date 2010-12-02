class AddColumnsToSpDonation < ActiveRecord::Migration
  def self.up
    add_column :sp_donations, :people_id, :string
    add_column :sp_donations, :donor_name, :string
    add_column :sp_donations, :donation_date, :date
    add_column :sp_donations, :address1, :string
    add_column :sp_donations, :address2, :string
    add_column :sp_donations, :address3, :string
    add_column :sp_donations, :city, :string
    add_column :sp_donations, :state, :string
    add_column :sp_donations, :zip, :string
    add_column :sp_donations, :phone, :string
    add_column :sp_donations, :email_address, :string
    add_column :sp_donations, :medium_type, :string
    add_column :sp_donations, :donation_id, :string
    change_column :sp_donations, :amount, :decimal, :precision => 10, :scale => 2
    add_index :sp_donations, :designation_number
    add_index :sp_donations, :donation_date
  end

  def self.down
    remove_index :sp_donations, :donation_date
    remove_index :sp_donations, :designation_number
    change_column :sp_donations, :amount, :double
    remove_column :sp_donations, :donation_id
    remove_column :sp_donations, :medium_type
    remove_column :sp_donations, :email_address
    remove_column :sp_donations, :phone
    remove_column :sp_donations, :zip
    remove_column :sp_donations, :state
    remove_column :sp_donations, :city
    remove_column :sp_donations, :address3
    remove_column :sp_donations, :address2
    remove_column :sp_donations, :address1
    remove_column :sp_donations, :donation_date
    remove_column :sp_donations, :donor_name
    remove_column :sp_donations, :people_id
  end
end