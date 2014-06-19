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
      person = create(:person)
      project = create(:sp_project)
      staff = create(:sp_staff, person_id: person.id, project_id: project.id, type: 'PD')

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      expect(assigns(:applications[project])).to eq(project)
      # expect(staff.person.directed_projects.last).to eq(project)
    end
  end
end
