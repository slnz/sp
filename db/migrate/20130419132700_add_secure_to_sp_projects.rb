class AddSecureToSpProjects < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :secure, :boolean
  end

  def self.down
    remove_column :sp_projects, :secure
  end
end
