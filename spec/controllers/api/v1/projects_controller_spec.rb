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
      response.should be_success
    end

    it 'returns projects array' do
      get 'index', access_token: api_key.access_token
      json = JSON.parse(response.body)
      json['projects'].should be_present
      json['projects'].should be_a(Array)
    end

    it 'returns invalid token msg' do
      get 'index', access_token: "1234"
      json = JSON.parse(response.body)
      json['error'].should be_present
    end

    %w{applicants pd apd opd staff volunteers}.each do |incl|
      context "include #{incl}" do
        it "returns project w/ #{incl}" do
          get 'index', include: incl, access_token: api_key.access_token
          json = JSON.parse(response.body)
          json['projects'].first.should have_key(incl)
        end
      end
    end

    context 'filter by id' do
      it 'returns specific person' do
        get 'index', filters: {id: project.id}, access_token: api_key.access_token
        json = JSON.parse(response.body)
        json['projects'].first['id'].to_i.should eq(project.id)
      end
    end

    context 'filter by primary_partner' do
      it 'returns specific person' do
        get 'index', filters: {primary_partner: 'String'}, access_token: api_key.access_token
        json = JSON.parse(response.body)
        json['projects'].first['primary_partner'].should eq('String')
      end
    end

    context 'filter by not_primary_partner' do
      it 'returns specific person' do
        get 'index', filters: {not_primary_partner: 'String'}, access_token: api_key.access_token
        json = JSON.parse(response.body)
        json['projects'].count.should eq(0)
      end
    end
  end

  context '#show' do
    it 'returns http success' do
      get 'show', id: project.id, access_token: api_key.access_token
      response.should be_success
    end

    it 'returns project' do
      get 'show', id: project.id, access_token: api_key.access_token
      json = JSON.parse(response.body)
      json['sp_project'].should be_present
    end
  end

end
