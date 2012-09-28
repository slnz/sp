class AddAppDatesToSpProject < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :open_application_date, :date, default: Date.parse("2012-11-01")
    add_column :sp_projects, :archive_project_date, :date, default: Date.parse("2012-08-31")
  end

  def self.down
    remove_column :sp_projects, :archive_project_date
    remove_column :sp_projects, :open_application_date
  end
end
