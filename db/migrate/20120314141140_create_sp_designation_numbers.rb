class CreateSpDesignationNumbers < ActiveRecord::Migration
  def self.up
    create_table :sp_designation_numbers do |t|
      t.integer :person_id
      t.integer :project_id
      t.string :designation_number

      t.timestamps
    end
  end

  def self.down
    drop_table :sp_designation_numbers
  end
end
