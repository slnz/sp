require 'spec_helper'

describe Fe::ChoiceField do
  describe "when calling 'ptemplate' function" do
    it 'returns a project_preference type' do
      expect(Fe::ChoiceField.new(style: 'project-preference').ptemplate).to eq 'fe/project_preference'
    end
  end
end
