require 'spec_helper'

describe ProjectsController do
  context '#show' do
    it 'responds to JSON with 200' do
      get :show, id: create(:sp_project).id, format: :json
      expect(response.status).to eq(200)
    end

    it 'responds to XML with 200' do
      get :show, id: create(:sp_project).id, format: :xml
      expect(response.status).to eq(200)
    end
  end

  context '#index' do
    it 'should list all the projects' do
      get :index
      should render_template('index')
    end
  end
end
