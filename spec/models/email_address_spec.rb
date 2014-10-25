require 'spec_helper'

describe EmailAddress do
  context '#async_push_to_global_registry' do
    it 'should async push the person and then async itself' do
      GlobalRegistry.access_token = 'access_token'
      GlobalRegistry.base_url = 'https://globalregistry.com/'

      p = create(:person)
      e = EmailAddress.new person: p

      allow(e).to receive(:person).and_return(p)
      expect(p).to receive(:async_push_to_global_registry).and_return(true)
      e.async_push_to_global_registry
      expect($async_push_to_global_registry_reached).to be true
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
      stub_request(:get, "https://globalregistry.com/entity_types?filters%5Bname%5D=person").
        to_return(:status => 200, :body => '{ "entity_types": [ { "id": 12345 } ] }', :headers => {})
      EmailAddress.push_structure_to_global_registry
      expect($push_structure_to_global_registry_reached).to be true
      expect($push_structure_to_global_registry_args.first).to eq(12345)
    end
  end
end
