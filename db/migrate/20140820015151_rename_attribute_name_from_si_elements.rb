class RenameAttributeNameFromSiElements < ActiveRecord::Migration
  def change
    renames = {
      contactName: "contact_name",
      contactRelationship: "contact_relationship",
      preferredPhone: "preferred_phone",
      homePhone: "home_phone",
      work_phone: "work_phone",
      cellPhone: "cell_phone"
    }

    renames.each do |a,b|
      Fe::Element.where(attribute_name: a).update_all(attribute_name: b)
    end
  end
end
