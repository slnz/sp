require 'spec_helper'

describe EmailAddress do
  before(:each) do
    $super_reached = false
    # this is easier than stub_request for all the global registry calls.. we're testing EmailAddress, not CruLib::GlobalRegistryMethods
    CruLib::GlobalRegistryMethods.class_eval do
      def async_push_to_global_registry(parent_id = nil, parent_type = nil, parent = nil)
        $super_reached = true
      end
    end
  end

  context '#async_push_to_global_registry' do
    it 'should async push the person and then async itself' do
      GlobalRegistry.access_token = 'access_token'
      GlobalRegistry.base_url = 'https://globalregistry.com/'

      p = create(:person)
      e = EmailAddress.new person: p

      allow(e).to receive(:person).and_return(p)
      expect(p).to receive(:async_push_to_global_registry).and_return(true)
      e.async_push_to_global_registry
      expect($super_reached).to be true
    end
  end

  context '#columns_to_push' do
    it 'should have email' do
      columns = EmailAddress.columns_to_push
      expect(columns.detect{ |c| c[:name] == 'email' }[:name]).to eq('email')
    end
  end

  context '#push_structure_to_global_registry' do
    it 'should work' do
      $super_reached = false
      # this is easier than stub_request for all the global registry calls.. we're testing EmailAddress, not CruLib::GlobalRegistryMethods
      CruLib::GlobalRegistryMethods::ClassMethods.class_eval do
        def push_structure_to_global_registry(parent_id = nil)
          $super_parent_id = parent_id
          $super_reached = true
        end
      end
      stub_request(:get, "https://globalregistry.com/entity_types?filters%5Bname%5D=person").
        to_return(:status => 200, :body => '{ "entity_types": [ { "id": 12345 } ] }', :headers => {})
      EmailAddress.push_structure_to_global_registry
      expect($super_reached).to be true
      expect($super_parent_id).to eq(12345)
    end
  end
end
