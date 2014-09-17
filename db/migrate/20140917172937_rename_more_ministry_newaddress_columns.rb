class RenameMoreMinistryNewaddressColumns < ActiveRecord::Migration
  def change
    rename_column :ministry_newaddress, :homePhone, :home_phone
    rename_column :ministry_newaddress, :workPhone, :work_phone
    rename_column :ministry_newaddress, :cellPhone, :cell_phone
  end
end
