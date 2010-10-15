class AddQuestionSheetFieldsToSpProject < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :basic_info_question_sheet_id, :integer
    add_column :sp_projects, :template_question_sheet_id, :integer
    add_column :sp_projects, :project_specific_question_sheet_id, :integer
  end

  def self.down
    remove_column :sp_projects, :project_specific_question_sheet_id
    remove_column :sp_projects, :template_question_sheet_id
    remove_column :sp_projects, :basic_info_question_sheet_id
  end
end
