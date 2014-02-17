class AddTimestampsToSpStaff < ActiveRecord::Migration
  def change
    add_column :sp_staff, :created_at, :datetime
    add_column :sp_staff, :updated_at, :datetime
  end
end
