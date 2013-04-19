class AddSecureToSpProjects < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :secured_location, :boolean
  end

  def self.down
    remove_column :sp_projects, :secured_location
  end
end
