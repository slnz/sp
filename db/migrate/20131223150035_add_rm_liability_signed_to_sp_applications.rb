class AddRmLiabilitySignedToSpApplications < ActiveRecord::Migration
  def change
    add_column :sp_applications, :rm_liability_signed, :tinyint
  end
end
