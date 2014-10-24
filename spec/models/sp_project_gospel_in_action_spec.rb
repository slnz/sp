require 'spec_helper'

describe SpStudentQuote do
  before(:all) do
    GlobalRegistry.access_token = 'access_token'
    GlobalRegistry.base_url = 'https://globalregistry.com/'
  end

  before(:each) do
    @gospel_in_action = create(:sp_gospel_in_action)
    @project = create(:sp_project)
    @sp_project_gospel_in_action = SpProjectGospelInAction.create! gospel_in_action: @gospel_in_action, project: @project
  end

  context '#async_push_to_global_registry' do
    before(:each) do
      $super_reached = false
      # this is easier than stub_request for all the global registry calls
      CruLib::GlobalRegistryMethods.class_eval do
        def async_push_to_global_registry
          $super_reached = true
        end
      end
    end

    it 'should work' do
      $super_reached = false
      @sp_project_gospel_in_action.async_push_to_global_registry
      expect($super_reached).to be true
    end
  end

  context '#attributes_to_push' do
    before(:each) do
      $super_reached = $args = nil
      CruLib::GlobalRegistryRelationshipMethods.class_eval do
        def attributes_to_push(*args)
          $super_reached = true
          $args = args
          {}
        end
      end
    end

    it 'should work with a global_registry_id set' do
      @sp_project_gospel_in_action.attributes_to_push
      expect($super_reached).to be true
      expect($args.first).to have_key(:relationship_name)
      expect($args.first).to have_key(:related_name)
      expect($args.first).to have_key(:related_object)
      expect($args.first).to have_key(:base_object)
    end

    it 'should work with no global_registry_id set' do
      @sp_project_gospel_in_action.update_attribute(:global_registry_id, '12345')
      @sp_project_gospel_in_action.attributes_to_push
      expect($super_reached).to be true
      expect($args.first).to be nil
    end
  end

  context '#create_in_global_registry' do
    before(:each) do
      $args = nil
      CruLib::GlobalRegistryRelationshipMethods.class_eval do
        def create_in_global_registry(*args)
          $args = *args
        end
      end
    end
    it 'should work' do
      @sp_project_gospel_in_action.create_in_global_registry
      expect($args.first).to eq(@project)
      expect($args.second).to eq('gospel_in_action')
    end
  end

  context 'SpProjectGospelInAction#push_structure_to_global_registry' do
    before(:each) do
      $base_type = $related_type = $relationship1_name = $relationship2_name
      CruLib::GlobalRegistryRelationshipMethods::ClassMethods.class_eval do
        def push_structure_to_global_registry(base_type, related_type, relationship1_name, relationship2_name)
          $base_type = base_type
          $related_type = related_type
          $relationship1_name = relationship1_name
          $relationship2_name = relationship2_name
        end
      end
    end
    it 'should work' do
      SpProjectGospelInAction.push_structure_to_global_registry
      expect($base_type).to eq(SpProject)
      expect($related_type).to eq(SpGospelInAction)
      expect($relationship1_name).to eq('project')
      expect($relationship2_name).to eq('gospel_in_action')
    end
  end

  context 'SpProjectGospelInAction#skip_fields_for_gr' do
    it 'should reutrn an array' do
      expect(SpProjectGospelInAction.skip_fields_for_gr.class).to be Array
    end
  end
end
