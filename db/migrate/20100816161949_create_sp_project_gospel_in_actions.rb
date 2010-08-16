class CreateSpProjectGospelInActions < ActiveRecord::Migration
  def self.up
    create_table :sp_project_gospel_in_actions do |t|
      t.integer :gospel_in_action_id
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sp_project_gospel_in_actions
  end
end
