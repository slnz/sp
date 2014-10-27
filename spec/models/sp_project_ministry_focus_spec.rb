require 'spec_helper'

describe SpProjectMinistryFocus do
  before(:all) do
    GlobalRegistry.access_token = 'access_token'
    GlobalRegistry.base_url = 'https://globalregistry.com/'
  end

  before(:each) do
    @person = create(:person)
    @user = create(:sp_user, person: @person)
    @project = create(:sp_project)
    @staff = create(:sp_staff, person: @person, sp_project: @project)
    @sp_ministry_focus = create(:sp_ministry_focus)
    @sp_project_ministry_focus = create(:sp_project_ministry_focus, ministry_focus: @sp_ministry_focus, project: @project)
  end

  context '#async_push_to_global_registry' do
    it 'should push ministry_focus and project if neither already have a global_registry_id' do
      allow(@sp_project_ministry_focus).to receive(:ministry_focus).and_return(@sp_ministry_focus)
      expect(@sp_ministry_focus).to receive(:async_push_to_global_registry)
      allow(@sp_project_ministry_focus).to receive(:project).and_return(@project)
      expect(@project).to receive(:async_push_to_global_registry)
      @sp_project_ministry_focus.async_push_to_global_registry
      expect($async_push_to_global_registry_reached).to be true
    end
  end

  context '#attributes_to_push' do
    it 'should set attributes when there is a global_registry_id value already' do
      @sp_project_ministry_focus.update_attribute(:global_registry_id, 12345)
      atts = @sp_project_ministry_focus.attributes_to_push
      expect($attributes_to_push_args).to eq([])
    end
    it 'should call super with no atts with no global_registry_id' do
      atts = @sp_project_ministry_focus.attributes_to_push
      expect(($attributes_to_push_args.first.keys & [:relationship_name, :related_name, :related_object, :base_object]).length).to eq(4)
    end
  end

  context '#create_in_global_registry' do
    it 'should work' do
      @sp_project_ministry_focus.create_in_global_registry
      expect($created_in_global_registry_reached).to be true
      expect($created_in_global_registry_args.first).to eq(@project)
    end
  end

  context '#push_structure_to_global_registry' do
    it 'should work' do
      SpProjectMinistryFocus.push_structure_to_global_registry
      expect($push_structure_to_global_registry_reached).to be true
    end
  end

  context '#skip_fields_for_gr' do
    it 'should work' do
      SpProjectMinistryFocus.skip_fields_for_gr
    end
  end

  context '#global_registry_entity_type_name' do
    it 'should work' do
      expect(SpProjectMinistryFocus.global_registry_entity_type_name).to eq('summer_project_project_ministry_focus')
    end
  end
end
