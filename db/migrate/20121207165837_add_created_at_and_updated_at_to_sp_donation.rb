class AddCreatedAtAndUpdatedAtToSpDonation < ActiveRecord::Migration
  def self.up
    add_column :sp_donations, :created_at, :datetime
    add_column :sp_donations, :updated_at, :datetime
  end

  def self.down
    remove_column :sp_donations, :updated_at
    remove_column :sp_donations, :created_at
  end
end
