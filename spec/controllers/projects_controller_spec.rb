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

  context '#index' do
    it 'should test for params[:year]' do
      create(:sp_project,
             start_date: Date.new(2014, 1, 1),
             end_date: Date.new(2014, 2, 1)
      )

      project = create(:sp_project,
                       start_date: Date.new(2013, 6, 1),
                       end_date: Date.new(2013, 8, 1)
      )

      get :index, year: '2013', start_month: '5', format: :json
      expect(assigns(:projects)).to eq([project])
    end
  end
end
