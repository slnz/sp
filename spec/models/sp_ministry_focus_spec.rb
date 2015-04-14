require 'spec_helper'

describe SpMinistryFocus do
  include_examples 'global_registry_methods'

  context '#to_s' do
    it 'should reutrn name' do
      f = SpMinistryFocus.new name: 'name'
      expect(f.to_s).to eq('name')
    end
  end

  context '#global_registry_entity_type_name' do
    it 'should be summer_project_ministry_focus' do
      expect(SpMinistryFocus.global_registry_entity_type_name).to eq('summer_project_ministry_focus') # easy...
    end
  end
end
