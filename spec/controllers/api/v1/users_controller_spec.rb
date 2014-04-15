require 'spec_helper'

describe Api::V1::UsersController do
  let(:api_key) { create(:api_key) }
  let!(:user) { create(:user) }

  before do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  context '#index' do
    it 'returns http success' do
      get 'index', access_token: api_key.access_token
      response.should be_success
    end

    it 'returns users array' do
      get 'index', access_token: api_key.access_token
      json = JSON.parse(response.body)
      json['users'].should be_present
      json['users'].should be_a(Array)
    end

    it 'returns invalid token msg' do
      get 'index', access_token: "1234"
      json = JSON.parse(response.body)
      json['error'].should be_present
    end
  end

  context '#show' do
    it 'returns http success' do
      get 'show', id: user.id, access_token: api_key.access_token
      response.should be_success
    end

    it 'returns user' do
      get 'show', id: user.id, access_token: api_key.access_token
      json = JSON.parse(response.body)
      json['user'].should be_present
    end
  end


end
