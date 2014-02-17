class AddFundRaisingColumnsToProject < ActiveRecord::Migration
  def change
    add_column :sp_projects, :project_summary, :text
    add_column :sp_projects, :full_project_description, :text
  end
end
