class ChangeMinistryFocusesProjecsToHasManyThrough < ActiveRecord::Migration
  def self.up
    rename_table :sp_ministry_focuses_projects, :sp_project_ministry_focuses

    change_table :sp_project_ministry_focuses do |t|
      t.rename :sp_project_id, :project_id
      t.rename :sp_ministry_focus_id, :ministry_focus_id
      t.column :id, :integer, primary_key: true, null: false, auto_increment: true
      t.timestamps
      t.column :global_registry_id, :bigint
    end
  end

  def self.down
    rename_table :sp_project_ministry_focuses, :sp_ministry_focuses_projects

    change_table :sp_ministry_focuses_projects do |t|
      t.rename :project_id, :sp_project_id
      t.rename :ministry_focus_id, :sp_ministry_focus_id
      t.remove :id
      t.remove :created_at
      t.remove :updated_at
      t.remove :global_registry_id
    end

  end
end
