class AddFePrefixToElements < ActiveRecord::Migration
  def change
    %w(TextField Paragraph ChoiceField Section StateChooser DateField SchoolPicker ProjectPreference QuestionGrid ReferenceQuestion PaymentQuestion).each do |class_name|
      Fe::Element.where(kind: class_name).update_all(kind: "Fe::#{class_name}")
    end
  end
end
