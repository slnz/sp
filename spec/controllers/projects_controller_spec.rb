require 'spec_helper'

describe ProjectsController do
  context '#show' do
    it 'responds to JSON with 200' do
      get :show, id: create(:sp_project).id, format: :json
      should respond_with 200
    end

    it 'responds to XML with 200' do
      get :show, id: create(:sp_project).id, format: :xml
      should respond_with 200
    end
  end
end
