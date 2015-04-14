require 'spec_helper'

describe Api::V1::PeopleController do
  let(:api_key) { create(:api_key) }
  let!(:person) { create(:person) }

  before do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  context '#index' do
    it 'returns http success' do
      get 'index', access_token: api_key.access_token
      expect(response).to be_success
    end

    it 'returns people array' do
      get 'index', access_token: api_key.access_token
      json = JSON.parse(response.body)
      expect(json['people']).to be_present
      expect(json['people']).to be_a(Array)
    end

    it 'returns invalid token msg' do
      get 'index', access_token: '1234'
      json = JSON.parse(response.body)
      expect(json['error']).to be_present
    end

    %w(email_addresses phone_numbers).each do |incl|
      context "include #{incl}" do
        it "returns people w/ #{incl}" do
          get 'index', include: incl, access_token: api_key.access_token
          json = JSON.parse(response.body)
          expect(json['people'].first).to have_key(incl)
        end
      end
    end

    context 'filter by id' do
      it 'returns specific person' do
        get 'index', filters: { id: person.id }, access_token: api_key.access_token
        json = JSON.parse(response.body)
        expect(json['people'].first['id'].to_i).to eq(person.id)
      end
    end
  end

  context '#show' do
    it 'returns http success' do
      get 'show', id: person.id, access_token: api_key.access_token
      expect(response).to be_success
    end

    it 'returns person' do
      get 'show', id: person.id, access_token: api_key.access_token
      json = JSON.parse(response.body)
      expect(json['person']).to be_present
    end
  end
end
