class ChangeRemovedFromPeopleSoftDefault < ActiveRecord::Migration
  def change
    change_column :ministry_staff, "removedFromPeopleSoft", :string, default: 'N' 
  end
end
