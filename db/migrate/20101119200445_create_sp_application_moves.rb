class CreateSpApplicationMoves < ActiveRecord::Migration
  def self.up
    create_table :sp_application_moves do |t|
      t.integer :application_id
      t.integer :old_project_id
      t.integer :new_project_id
      t.integer :moved_by_person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sp_application_moves
  end
end
