class AddBackgroundChecksRequiredToSpProjects < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :background_checks_required, :boolean, :default => false
  end

  def self.down
    remove_column :sp_projects, :background_checks_required
  end
end
