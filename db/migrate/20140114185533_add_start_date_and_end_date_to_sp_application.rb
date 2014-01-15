class AddStartDateAndEndDateToSpApplication < ActiveRecord::Migration
  def change
    add_column :sp_applications, :start_date, :date
    add_column :sp_applications, :end_date, :date
  end
end
