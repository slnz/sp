class ChangeMinistryNewaddressPrimaryKeyToId < ActiveRecord::Migration
  def change
    rename_column :ministry_newaddress, :addressID, :id
  end
end
