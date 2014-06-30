require 'spec_helper'

describe ChoiceField do
  
  describe "when calling 'ptemplate' function" do
    it 'returns a nil if style is nil' do
      expect(ChoiceField.new().ptemplate).to be_nil
    end
    it 'returns a checkbox_field type' do
      expect(ChoiceField.new(style: 'checkbox').ptemplate).to eq 'checkbox_field'
    end
    it 'returns a drop_down_field type' do
      expect(ChoiceField.new(style: 'drop-down').ptemplate).to eq 'drop_down_field'
    end
    it 'returns a radio_button_field type' do
      expect(ChoiceField.new(style: 'radio').ptemplate).to eq 'radio_button_field'
    end
    it 'returns a yes_no type' do
      expect(ChoiceField.new(style: 'yes-no').ptemplate).to eq 'yes_no'
    end
    it 'returns a rating type' do
      expect(ChoiceField.new(style: 'rating').ptemplate).to eq 'rating'
    end
    it 'returns a acceptance type' do
      expect(ChoiceField.new(style: 'acceptance').ptemplate).to eq 'acceptance'
    end
    it 'returns a country type' do
      expect(ChoiceField.new(style: 'country').ptemplate).to eq 'country'
    end
    it 'returns a project_preference type' do
      expect(ChoiceField.new(style: 'project-preference').ptemplate).to eq 'project_preference'
    end
  end
  
end