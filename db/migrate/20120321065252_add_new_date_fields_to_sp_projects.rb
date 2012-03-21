class AddNewDateFieldsToSpProjects < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :pd_start_date, :date
    add_column :sp_projects, :pd_end_date, :date
    add_column :sp_projects, :pd_close_start_date, :date
    add_column :sp_projects, :pd_close_end_date, :date
    add_column :sp_projects, :student_staff_start_date, :date
    add_column :sp_projects, :student_staff_end_date, :date
  end

  def self.down
    remove_column :sp_projects, :pd_start_date
    remove_column :sp_projects, :pd_end_date
    remove_column :sp_projects, :pd_close_start_date
    remove_column :sp_projects, :pd_close_end_date
    remove_column :sp_projects, :student_staff_start_date
    remove_column :sp_projects, :student_staff_end_date
  end
end
