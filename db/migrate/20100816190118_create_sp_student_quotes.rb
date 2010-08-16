class CreateSpStudentQuotes < ActiveRecord::Migration
  def self.up
    create_table :sp_student_quotes do |t|
      t.integer :project_id
      t.text :quote
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :sp_student_quotes
  end
end
