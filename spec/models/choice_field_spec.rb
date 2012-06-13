require 'spec_helper'

describe ChoiceField do
  
  describe "when calling 'ptemplate' function" do
    it 'should return a nil if style is nil' do
      ChoiceField.new().ptemplate.should be nil
    end
    it 'should return a checkbox_field type' do
      ChoiceField.new(style: 'checkbox').ptemplate.should == 'checkbox_field'
    end
    it 'should return a drop_down_field type' do
      ChoiceField.new(style: 'drop-down').ptemplate.should == 'drop_down_field'
    end
    it 'should return a radio_button_field type' do
      ChoiceField.new(style: 'radio').ptemplate.should == 'radio_button_field'
    end
    it 'should return a yes_no type' do
      ChoiceField.new(style: 'yes-no').ptemplate.should == 'yes_no'
    end
    it 'should return a rating type' do
      ChoiceField.new(style: 'rating').ptemplate.should == 'rating'
    end
    it 'should return a acceptance type' do
      ChoiceField.new(style: 'acceptance').ptemplate.should == 'acceptance'
    end
    it 'should return a country type' do
      ChoiceField.new(style: 'country').ptemplate.should == 'country'
    end
    it 'should return a project_preference type' do
      ChoiceField.new(style: 'project-preference').ptemplate.should == 'project_preference'
    end
  end
  
end