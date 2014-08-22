class DropRegionsTable < ActiveRecord::Migration
  def change
    drop_table :ministry_regionalteam
  end
end
