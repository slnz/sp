class AddHighSchoolToSpProject < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :high_school, :boolean, :default => false
  end

  def self.down
    remove_column :sp_projects, :high_school
  end
end
