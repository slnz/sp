class ChangeStartEndDateToDateOnSpProject < ActiveRecord::Migration
  def self.up
    change_column :sp_projects, :start_date, :date
    change_column :sp_projects, :end_date, :date
    change_column :sp_projects, :date_of_departure, :date
    change_column :sp_projects, :date_of_return, :date
    
  end

  def self.down
    change_column :sp_projects, :start_date, :datetime
    change_column :sp_projects, :end_date, :datetime
    change_column :sp_projects, :date_of_departure, :datetime
    change_column :sp_projects, :date_of_return, :datetime
  end
end
