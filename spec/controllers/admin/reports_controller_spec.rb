require 'spec_helper'

describe Admin::ReportsController do
  let(:user) { create(:user) }

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
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      person = create(:person)
      project = create(:sp_project)
      staff = create(:sp_staff, person_id: person.id, project_id: project.id, type: 'PD')

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      # expect(assigns(:applications[project])).to eq([project])
      expect(staff.person.directed_projects.last).to eq(project)
    end
  end

  context '#male_openings' do
    it 'calculates percentage of men in a project via HTML - 0-50%' do
      create(:sp_national_coordinator, user: user)
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
      create(:sp_national_coordinator, user: user)
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

  context '#ministry_focus' do
    it 'sorts projects by ministry focus' do
      focus = SpMinistryFocus.create(name: 'String')
      focuses = SpMinistryFocus.order(:name)

      # expect(assigns(:focuses)).to eq([focus])
      expect(focuses).to eq([focus])
    end

    it 'sorts projects by ministry focus via CSV' do
      focus = SpMinistryFocus.create(name: 'String')
      focuses = SpMinistryFocus.order(:name)

      get :ministry_focus, format: :csv
      expect(response.status).to eq(200)
    end

    it 'sorts projects by ministry focus via HTML' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :ministry_focus, format: :html
      expect(response.status).to eq(200)
    end
  end
end
