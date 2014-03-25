class ChangeDesignationNumberToString < ActiveRecord::Migration
  def change
    change_column :sp_donations, :designation_number, :string
    while SpDonation.where("length(designation_number) < 7").first do
      SpDonation.connection.execute("update sp_donations set designation_number = CONCAT('0', designation_number) where length(designation_number) < 7")
    end
  end
end
