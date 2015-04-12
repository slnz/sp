class RenameMinistryPersonAccountNo < ActiveRecord::Migration
  def change
    rename_column :ministry_person, :accountNo, :account_no
  end
end
