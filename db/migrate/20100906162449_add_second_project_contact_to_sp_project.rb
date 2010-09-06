class AddSecondProjectContactToSpProject < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :project_contact2_name, :string
    add_column :sp_projects, :project_contact2_role, :string
    add_column :sp_projects, :project_contact2_phone, :string
    add_column :sp_projects, :project_contact2_email, :string
    
    add_column :sp_project_versions, :project_contact2_name, :string
    add_column :sp_project_versions, :project_contact2_role, :string
    add_column :sp_project_versions, :project_contact2_phone, :string
    add_column :sp_project_versions, :project_contact2_email, :string
  end

  def self.down
    remove_column :sp_project_versions, :project_contact2_email
    remove_column :sp_project_versions, :project_contact2_phone
    remove_column :sp_project_versions, :project_contact2_role
    remove_column :sp_project_versions, :project_contact2_name
    
    remove_column :sp_projects, :project_contact2_email
    remove_column :sp_projects, :project_contact2_phone
    remove_column :sp_projects, :project_contact2_role
    remove_column :sp_projects, :project_contact2_name
  end
end
