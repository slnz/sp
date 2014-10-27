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
    it 'should work' do
      $super_reached = false
      @sp_project_gospel_in_action.async_push_to_global_registry
      expect($async_push_to_global_registry_reached).to be true
    end
  end

  context '#attributes_to_push' do
    it 'should work with a global_registry_id set' do
      @sp_project_gospel_in_action.attributes_to_push
      expect($attributes_to_push_reached).to be true
      expect($attributes_to_push_args.first).to have_key(:relationship_name)
      expect($attributes_to_push_args.first).to have_key(:related_name)
      expect($attributes_to_push_args.first).to have_key(:related_object)
      expect($attributes_to_push_args.first).to have_key(:base_object)
    end

    it 'should work with no global_registry_id set' do
      @sp_project_gospel_in_action.update_attribute(:global_registry_id, '12345')
      @sp_project_gospel_in_action.attributes_to_push
      expect($attributes_to_push_reached).to be true
      expect($attributes_to_push_args.first).to be nil
    end
  end

  context '#create_in_global_registry' do
    it 'should work' do
      @sp_project_gospel_in_action.create_in_global_registry
      expect($created_in_global_registry_reached).to be true
      expect($created_in_global_registry_args.first).to eq(@project)
      expect($created_in_global_registry_args.second).to eq('gospel_in_action')
    end
  end

  context 'SpProjectGospelInAction#push_structure_to_global_registry' do
    it 'should work' do
      SpProjectGospelInAction.push_structure_to_global_registry
      expect($push_structure_to_global_registry_reached).to be true
      expect($push_structure_to_global_registry_args.first).to eq(SpProject)
      expect($push_structure_to_global_registry_args.second).to eq(SpGospelInAction)
      expect($push_structure_to_global_registry_args.third).to eq('project')
      expect($push_structure_to_global_registry_args.fourth).to eq('gospel_in_action')
    end
  end

  context 'SpProjectGospelInAction#skip_fields_for_gr' do
    it 'should return an array' do
      expect(SpProjectGospelInAction.skip_fields_for_gr.class).to be Array
    end
  end
end
