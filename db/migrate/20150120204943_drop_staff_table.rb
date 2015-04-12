class DropStaffTable < ActiveRecord::Migration
  def change
    drop_table :ministry_staff
  end
end
