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

    # BAD SPEC!!! This needs to be rewritten
    # review projects_controller#show line 8
    it 'responds to XML with 200 and <sp-project/> in body' do
      project = create(:sp_project)
      project.project_status = 'closed'
      project.show_on_website = false

      get :show, id: project.id, format: :xml
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

    it 'should test for params[:all] true' do
      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      project = create(:sp_project, open_application_date: open_application_date, start_date: start_date, end_date: end_date)

      get :index, all: 'true'

      if project.project_status == 'open' && (project.open_application_date <= Date.today && project.start_date >= Date.today)
        expect(assigns(:projects)).to eq [project]
      end
    end

    it 'should test for most params' do
      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60

      project = create(:sp_project,
                       open_application_date: open_application_date,
                       start_date: start_date,
                       end_date: end_date,

                       name: 'Orl Ruby Dojo',
                       city: 'Orlando',
                       state: 'FL',
                       country: 'United States',
                       world_region: 'USA/Canada',
                       job: 1
      )

      focus = SpMinistryFocus.create(name: 'Coders')
      ministry_focus = SpProjectMinistryFocus.create(project_id: project.id, ministry_focus_id: focus.id)

      get :index,
          start_month: 3,
          end_month: 12,
          from_weeks: 3,
          name: 'Orl Ruby Dojo',
          to_weeks: 4,
          focus_name: focus.name,
          focus: focus.id,
          world_region: 'USA/Canada',
          country: 'United States',
          project_type: 'US',
          job: 1,
          city: 'Orlando'

      expect(assigns(:projects)).to eq([project])
    end
  end
end
