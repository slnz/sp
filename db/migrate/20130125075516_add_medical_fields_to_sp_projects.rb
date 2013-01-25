class AddMedicalFieldsToSpProjects < ActiveRecord::Migration
  def self.up
    add_column :sp_projects, :medical_clinic, :string, after: "in_country_contact"
    add_column :sp_projects, :medical_clinic_location, :string, after: "medical_clinic"
  end

  def self.down
    remove_column :sp_projects, :medical_clinic_location
    remove_column :sp_projects, :medical_clinic
  end
end
