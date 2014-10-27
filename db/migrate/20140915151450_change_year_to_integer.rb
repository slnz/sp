class ChangeYearToInteger < ActiveRecord::Migration
  def change
    change_column :sp_staff, :year, 'integer USING CAST(year AS integer)'
  end
end
