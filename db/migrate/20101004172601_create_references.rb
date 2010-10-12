class CreateReferences < ActiveRecord::Migration
  def self.up
    add_column :sp_references, :question_id, :integer
    add_column :sp_references, :answer_sheet_id, :integer
    add_column :sp_references, :response_id, :integer
    
    add_column Element.table_name, :related_question_sheet_id, :integer
  end

  def self.down
    remove_column :sp_references, :response_id
    remove_column :sp_references, :answer_sheet_id
    remove_column :sp_references, :question_id
    remove_column Element.table_name, :related_question_sheet_id
    drop_table :references
  end
end