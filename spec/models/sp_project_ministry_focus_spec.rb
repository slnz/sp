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
    before(:each) do
      $super_reached = false
      # this is easier than stub_request for all the global registry calls
      CruLib::GlobalRegistryMethods.class_eval do
        def async_push_to_global_registry
          $super_reached = true
        end
      end
    end

    it 'should push ministry_focus and project if neither already have a global_registry_id' do
      allow(@sp_project_ministry_focus).to receive(:ministry_focus).and_return(@sp_ministry_focus)
      expect(@sp_ministry_focus).to receive(:async_push_to_global_registry)
      allow(@sp_project_ministry_focus).to receive(:project).and_return(@project)
      expect(@project).to receive(:async_push_to_global_registry)
      @sp_project_ministry_focus.async_push_to_global_registry
      expect($super_reached).to be true
    end
  end

  context '#attributes_to_push' do
    before(:each) do
      $args = nil
      puts "in sp_project_ministry_focus_spec.rb, defining attributes_to_push next"
      CruLib::GlobalRegistryMethods.class_eval do
        def attributes_to_push(*args)
          $super_reached = true
          puts "in sp_project_ministry_focus_spec.rb attributes_to_push"
          $args = args
          {}
        end
      end
    end
    it 'should set attributes when there is a global_registry_id value already' do
      @sp_project_ministry_focus.update_attribute(:global_registry_id, 12345)
      atts = @sp_project_ministry_focus.attributes_to_push
      puts $args.inspect
      expect(($args.first.keys & [:relationship_name, :related_name, :related_object, :base_object]).length).to eq(4)
    end
    it 'should call super with no atts with no global_registry_id' do
      atts = @sp_project_ministry_focus.attributes_to_push
      expect($args).to be nil
    end
  end

  context '#create_in_global_registry' do
    before(:each) do
      CruLib::GlobalRegistryRelationshipMethods.class_eval do
        def create_in_global_registry(*args)
          $super_reached = true
          $args = args
        end
      end
    end
    it 'should work' do
      @sp_project_ministry_focus.create_in_global_registry
      expect($args.first).to eq(@project)
    end
  end

  context '#push_structure_to_global_registry' do
    before(:each) do
      CruLib::GlobalRegistryRelationshipMethods::ClassMethods.class_eval do
        def push_structure_to_global_registry(*args)
          $super_reached = true
          $args = args
        end
      end
    end
    it 'should work' do
      SpProjectMinistryFocus.push_structure_to_global_registry
    end
  end

  context '#skip_fields_for_gr' do
    before(:each) do
      CruLib::GlobalRegistryRelationshipMethods::ClassMethods.class_eval do
        def create_in_global_registry(*args)
          $super_reached = true
          $args = args
        end
      end
    end
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
