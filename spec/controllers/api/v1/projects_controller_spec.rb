require 'spec_helper'

describe Api::V1::ProjectsController do
  let(:api_key) { create(:api_key) }
  let!(:project) { create(:sp_project) }

  before do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  context '#index' do
    it 'returns http success' do
      get 'index', access_token: api_key.access_token
      expect(response).to be_success
    end

    it 'can grab the token from header' do
      request.env['HTTP_AUTHORIZATION'] = "token #{api_key.access_token}"
      get 'index'
      expect(response).to be_success
    end

    it 'can handle an invalid HTTP_AUTHORIZATION value' do
      request.env['HTTP_AUTHORIZATION'] = '12345'
      get 'index'
      json = JSON.parse(response.body)
      expect(json['error']).to be_present
    end

    it 'returns projects array' do
      get 'index', access_token: api_key.access_token
      json = JSON.parse(response.body)
      expect(json['projects']).to be_present
      expect(json['projects']).to be_a(Array)
    end

    it 'returns invalid token msg' do
      get 'index', access_token: '1234'
      json = JSON.parse(response.body)
      expect(json['error']).to be_present
    end

    %w(applicants pd apd opd staff volunteers).each do |incl|
      context "include #{incl}" do
        it "returns project w/ #{incl}" do
          get 'index', include: incl, access_token: api_key.access_token
          json = JSON.parse(response.body)
          expect(json['projects'].first).to have_key(incl)
        end
      end
    end

    context 'filter by id' do
      it 'returns specific person' do
        get 'index', filters: { id: project.id }, access_token: api_key.access_token
        json = JSON.parse(response.body)
        expect(json['projects'].first['id'].to_i).to eq(project.id)
      end
    end

    context 'filter by primary_partner' do
      it 'returns specific person' do
        get 'index', filters: { primary_partner: 'String' }, access_token: api_key.access_token
        json = JSON.parse(response.body)
        expect(json['projects'].first['primary_partner']).to eq('String')
      end
    end

    context 'filter by not_primary_partner' do
      it 'returns specific person' do
        get 'index', filters: { not_primary_partner: 'String' }, access_token: api_key.access_token
        json = JSON.parse(response.body)
        expect(json['projects'].count).to eq(0)
      end
    end
  end

  context '#show' do
    it 'returns http success' do
      get 'show', id: project.id, access_token: api_key.access_token
      expect(response).to be_success
    end

    it 'returns project' do
      get 'show', id: project.id, access_token: api_key.access_token
      json = JSON.parse(response.body)
      expect(json['sp_project']).to be_present
    end
    it 'returns 404 if the person is not found' do
      get 'show', id: 12_345, access_token: api_key.access_token
      expect(response.status).to eq(404)
    end
  end
end
