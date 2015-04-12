class ChangeSiElementsAttributeNameValuesForPhoneColumns < ActiveRecord::Migration
  def change
    Fe::Element.where(attribute_name: "workPhone").update_all(attribute_name: "work_phone")
    Fe::Element.where(attribute_name: "homePhone").update_all(attribute_name: "home_phone")
    Fe::Element.where(attribute_name: "cellPhone").update_all(attribute_name: "cell_phone")
  end
end
