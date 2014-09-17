class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :ministry_person, :personID, :id
    rename_column :ministry_person, :firstName, :first_name
    rename_column :ministry_person, :lastName, :last_name
    rename_column :ministry_person, :preferredName, :preferred_name
    rename_column :ministry_person, :middleName, :middle_name
  end
end
