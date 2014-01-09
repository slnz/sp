class ChangeColumnRmLiabilitySignedType < ActiveRecord::Migration
  def change
	  change_column :sp_applications, :rm_liability_signed, :boolean
  end
end
