class ChangeMinistryNewaddressColumnToBeMoreRailsLike < ActiveRecord::Migration
  def change
    rename_column :ministry_newaddress, :contactName, :contact_name
    rename_column :ministry_newaddress, :contactRelationship, :contact_relationship
    rename_column :ministry_newaddress, :addressType, :address_type
    rename_column :ministry_newaddress, :dateCreated, :created_at
    rename_column :ministry_newaddress, :dateChanged, :updated_at
    rename_column :ministry_newaddress, :createdBy, :created_by
    rename_column :ministry_newaddress, :changedBy, :changed_by
    rename_column :ministry_newaddress, :fk_PersonID, :person_id
    rename_column :ministry_newaddress, :preferredPhone, :preferred_phone
  end
end
