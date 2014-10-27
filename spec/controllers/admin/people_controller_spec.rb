require 'spec_helper'

describe Admin::PeopleController do
  let(:user) { create(:user, person: create(:person)) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#show' do
    it {
      project = create(:sp_project)

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      designation = SpDesignationNumber.create(person_id: applicant, project_id: project, designation_number: '12345')

      xhr :get, :show, id: applicant.id, project_id: project.id, year: SpApplication.year
      expect(response.code).to eq('200')
      expect(assigns(:application)).to eq(application)
    }
  end

  context '#update' do
    it 'update w/ project > 0' do
      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      year = SpApplication.year
      project = create(:sp_project,
                       open_application_date: open_application_date,
                       start_date: start_date,
                       end_date: end_date
      )

      designation_number = '12345'

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      designation = SpDesignationNumber.create(person_id: applicant.id,
                                               project_id: project.id,
                                               designation_number: designation_number,
                                               year: year
      )

      xhr :put, :update, id: applicant.id, project_id: project.id, designation_number: designation_number, sp_application: application.id, year: year
      expect(assigns(:designation)).to eq(designation)
      expect(assigns(:application)).to eq(application)
    end
    it 'update w/ project > 0 while creating new designation number' do
      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      year = SpApplication.year
      project = create(:sp_project,
                       open_application_date: open_application_date,
                       start_date: start_date,
                       end_date: end_date
      )

      designation_number = '12345'

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      xhr :put, :update, id: applicant.id, project_id: project.id, designation_number: designation_number, sp_application: application.id, year: year
      expect(assigns(:designation))
      expect(assigns(:application)).to eq(application)
    end
  end
end
