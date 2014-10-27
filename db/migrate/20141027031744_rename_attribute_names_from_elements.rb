class RenameAttributeNamesFromElements < ActiveRecord::Migration
  def change
    renames = {
      contactName: "contact_name",
      contactRelationship: "contact_relationship",
      preferredPhone: "preferred_phone",
      homePhone: "home_phone",
      workPhone: "work_phone",
      cellPhone: "cell_phone",
      firstName: "first_name",
      lastName: "last_name",
      middleName: "middle_name",
      preferredName: "preferred_name"
    }

    renames.each do |a,b|
      base = Fe::Element.where(attribute_name: a)
      puts "Update #{Fe::Element.table_name}.attribute_name text '#{a}' -> '#{b}' (#{base.count})"
      base.update_all(attribute_name: b)
    end
  end
end
