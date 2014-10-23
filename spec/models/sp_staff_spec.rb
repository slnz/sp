require 'spec_helper'

describe SpStaff do
  before(:all) do
    GlobalRegistry.access_token = 'access_token'
    GlobalRegistry.base_url = 'https://globalregistry.com/'
  end

  before(:each) do
    @person = create(:person)
    @user = create(:sp_user, person: @person)
    @project = create(:sp_project)
    @staff = create(:sp_staff, person: @person, sp_project: @project)
  end

  context '#designation_number=' do
    it 'should create a new SpDesignationNumber if there is not one already' do
      @staff.designation_number = '1234567'
      expect(@staff.designation_number).to eq('1234567')
    end
    it 'should set the designation_number of an existing designation for this staff' do
      dn = create(:sp_designation_number, person: @person, project: @project)
      @staff.designation_number = '1234567'
      expect(@staff.designation_number).to eq('1234567')
    end
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

    it 'should push person and sp_project if neither already have a global_registry_id' do
      allow(@staff).to receive(:person).and_return(@person)
      expect(@person).to receive(:async_push_to_global_registry)
      allow(@staff).to receive(:sp_project).and_return(@project)
      expect(@project).to receive(:async_push_to_global_registry)
      @staff.async_push_to_global_registry
      expect($super_reached).to be true
    end
    it 'should not push person if there is already a global_registry_id for it' do
      @person.update_column(:global_registry_id, '12345')
      allow(@staff).to receive(:person).and_return(@person)
      expect(@person).to_not receive(:async_push_to_global_registry)
      allow(@staff).to receive(:sp_project).and_return(@project)
      expect(@project).to receive(:async_push_to_global_registry)
      @staff.async_push_to_global_registry
      expect($super_reached).to be true
    end
    it 'should not push person if there is already a global_registry_id for it' do
      @project.update_column(:global_registry_id, '12345')
      allow(@staff).to receive(:person).and_return(@person)
      expect(@person).to receive(:async_push_to_global_registry)
      allow(@staff).to receive(:sp_project).and_return(@project)
      expect(@project).to_not receive(:async_push_to_global_registry)
      @staff.async_push_to_global_registry
      expect($super_reached).to be true
    end
  end

  context '#attributes_to_push' do
    it 'should set the role when there is a global_registry_id value already' do
      @staff.update_column(:global_registry_id, '12345')
      atts = @staff.attributes_to_push
      expect(atts['role']).to eq(@staff.type)
    end
    it "should work when there's no global_registry_id" do
      atts = @staff.attributes_to_push
      expect(atts.class).to be(Hash)
    end
  end

  context '#field_roles' do
    it 'should return an array of strings' do
      expect(Staff.field_roles.class).to be Array
      expect(Staff.field_roles.collect(&:class).uniq).to eq([String])
    end
  end

  context '#strategy_order' do
    it 'should return an array of strings' do
      expect(Staff.strategy_order.class).to be Array
      expect(Staff.strategy_order.collect(&:class).uniq).to eq([String])
    end
  end

  context '#strategies' do
    it 'should return a hash of strings to strings' do
      strategies = Staff.strategies
      expect(strategies.class).to be Hash
      expect(strategies.keys.collect(&:class).uniq).to eq([String])
      expect(strategies.values.collect(&:class).uniq).to eq([String])
    end
  end

  context '#staff_positions' do
    it 'should return a hash of strings to strings' do
      staff_positions = Staff.staff_positions
      expect(staff_positions.class).to be Array
      expect(staff_positions.collect(&:class).uniq).to eq([String])
    end
  end

  context '#specialty_roles' do
    it 'should work' do
      s = create(:staff, jobStatus: "Staff Full Time", ministry: "Campus Ministry", removedFromPeopleSoft: "N", jobTitle: "Specialty Title")
      expect(Staff.specialty_roles.length).to eq(1)
      expect(Staff.specialty_roles.first).to eq(s)
    end
  end
end
