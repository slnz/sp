require 'spec_helper'

describe PhoneNumber do
  before(:all) do
    GlobalRegistry.access_token = 'access_token'
    GlobalRegistry.base_url = 'https://globalregistry.com/'
  end

  before(:each) do
    @person = create(:person)
    @phone_number = PhoneNumber.create!(person: @person)
  end

  context '#async_push_to_global_registry' do
    it 'should push ministry_focus and project if neither already have a global_registry_id' do
      allow(@phone_number).to receive(:person).and_return(@person)
      expect(@person).to receive(:async_push_to_global_registry)
      $super_reached = false
      @phone_number.async_push_to_global_registry
      expect($async_push_to_global_registry_reached).to be true
    end
  end

  context '#push_structure_to_global_registry' do
    it 'should work' do
      $super_reached = false
      stub_request(:get, "https://globalregistry.com/entity_types?filters%5Bname%5D=person").
        to_return(:status => 200, :body => '{ "entity_types": [ { "fields": [ { "name": "something" } ] } ] }', :headers => {})
      stub_request(:get, "https://globalregistry.com/entity_types?filters%5Bname%5D=phone_number&filters%5Bparent_id%5D=12345").
        to_return(:status => 200, :body => '{ "entity_types": [ { "fields": [ { "name": "something" } ] } ] }', :headers => {})
      PhoneNumber.push_structure_to_global_registry
      expect($push_structure_to_global_registry_reached).to be true
    end
  end

  context '#skip_fields_for_gr' do
    it 'should work' do
      expect(PhoneNumber.skip_fields_for_gr.class).to be Array
    end
  end
end
