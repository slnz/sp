require 'spec_helper'

describe Admin::ReportsController do
  let(:user) { create(:user, person: create(:person)) }

  context '#show' do
    it 'determines if you are a director' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :show

      response.should redirect_to(action: :director)
    end
  end

  context '#preference' do
    it 'shows applications that prefer a project' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      project = create(:sp_project)
      staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      get :preference

      expect(assigns(:applications)[project]).to eq([application])
    end
  end

  context '#male_openings' do
    it 'calculates percentage of men in a project via HTML - 0-50%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_men = 2
      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60

      project = create(:sp_project,
                       max_accepted_men: max_accepted_men,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person, gender: '1')
      application = create(:sp_application,
                            person_id: applicant.id,
                            project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')


      get :male_openings
      expect(SpProject.current.uses_application.last.percent_full_men.to_i).to eq(50)
    end
  end

  context '#male_openings' do
    it 'calculates percentage of men in a project via HTML - 51-99%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_men = 3
      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      project = create(:sp_project,
                       max_accepted_men: max_accepted_men,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant1 = create(:person, gender: '1')
      application1 = create(:sp_application,
                            person_id: applicant1.id,
                            project_id: project.id
      )
      applicant2 = create(:person, gender: '1')
      application2 = create(:sp_application,
                            person_id: applicant2.id,
                            project_id: project.id
      )
      application1.update_attribute('status', 'accepted_as_participant')
      application2.update_attribute('status', 'accepted_as_participant')


      get :male_openings
      expect(SpProject.current.uses_application.last.percent_full_men.to_i).to eq(66)
    end
  end

  
end
