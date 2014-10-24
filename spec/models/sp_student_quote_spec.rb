require 'spec_helper'

describe SpStudentQuote do
  before(:all) do
    GlobalRegistry.access_token = 'access_token'
    GlobalRegistry.base_url = 'https://globalregistry.com/'
  end

  before(:each) do
    @project = create(:sp_project, global_registry_id: '5')
    @sp_student_quote = create(:sp_student_quote, project: @project)
  end

  context '#async_push_to_global_registry' do
    before(:each) do
      $super_reached = false
      # this is easier than stub_request for all the global registry calls
      CruLib::GlobalRegistryMethods.class_eval do
        def async_push_to_global_registry(a, b, c)
          $a = a
          $b = b
          $c = c
        end
      end
    end

    it 'should work' do
      $a = $b = $c = nil
      @sp_student_quote.async_push_to_global_registry
      expect($a).to eq(@project.global_registry_id)
      expect($b).to eq('summer_project')
      expect($c).to eq(@project)
    end
  end

  context '#push_structure_to_global_registry' do
    before(:each) do
      CruLib::GlobalRegistryMethods::ClassMethods.class_eval do
        def push_structure_to_global_registry(parent_id = nil)
          $super_reached = true
        end
      end
    end
    it 'should work' do
      $super_reached = false
      stub_request(:get, "https://globalregistry.com/entity_types?filters%5Bname%5D=summer_project").
        to_return(:status => 200, :body => '{ "entity_types": [ { "fields": [ { "id": "id123" } ] } ] }', :headers => {})
      SpStudentQuote.push_structure_to_global_registry
      expect($super_reached).to be true
    end
  end

  context '#attributes_to_push' do
    before(:each) do
      CruLib::GlobalRegistryMethods.class_eval do
        def attributes_to_push(*args)
          $super_reached = true
          $args = args
          {}
        end
      end
    end
  end

  context '#skip_fields_for_gr' do
    it 'should reutrn an array' do
      expect(SpStudentQuote.skip_fields_for_gr.class).to be Array
    end
  end

  context '#global_registry_entity_type_name' do
    it 'should return a string' do
      expect(SpStudentQuote.global_registry_entity_type_name.class).to be String
    end
  end
end
