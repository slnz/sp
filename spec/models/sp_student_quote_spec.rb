require 'spec_helper'

describe SpStudentQuote do
  include_examples "global_registry_methods"

  before(:all) do
    GlobalRegistry.access_token = 'access_token'
    GlobalRegistry.base_url = 'https://globalregistry.com/'
  end

  before(:each) do
    @project = create(:sp_project, global_registry_id: '5')
    @sp_student_quote = create(:sp_student_quote, project: @project)
  end

  context '#async_push_to_global_registry' do
    it 'should work' do
      @sp_student_quote.async_push_to_global_registry
      expect($async_push_to_global_registry_args.first).to eq(@project.global_registry_id)
      expect($async_push_to_global_registry_args.second).to eq('summer_project')
      expect($async_push_to_global_registry_args.third).to eq(@project)
    end
  end

  context '#push_structure_to_global_registry' do
    it 'should work' do
      $super_reached = false
      stub_request(:get, "https://globalregistry.com/entity_types?filters%5Bname%5D=summer_project").
        to_return(:status => 200, :body => '{ "entity_types": [ { "fields": [ { "id": "id123" } ] } ] }', :headers => {})
      SpStudentQuote.push_structure_to_global_registry
      expect($push_structure_to_global_registry_reached).to be true
    end
  end

  context '#global_registry_entity_type_name' do
    it 'should return a string' do
      expect(SpStudentQuote.global_registry_entity_type_name.class).to be String
    end
  end
end
