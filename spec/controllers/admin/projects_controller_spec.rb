require 'spec_helper'

describe Admin::ProjectsController do
  let(:user) { create(:user, person: create(:person)) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#index' do
    it 'lists open projects' do
      stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

      get :index
      expect(response).to render_template('index')
    end
  end

  context '#show' do
    it 'shows project details' do
      get :show, id: create(:sp_project).id
      expect(response).to render_template('show')
    end
  end

  context '#edit' do
    it 'shows project edit form' do
      stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

      get :edit, id: create(:sp_project).id
      expect(response).to render_template('edit')
    end
  end

  context '#destroy' do
    it 'deletes a project' do
      project = create(:sp_project)
      expect {
        delete :destroy, id: project.id
      }.to change(SpProject, :count).by(-1)
    end
  end

  context '#update' do
    let(:project) { create(:sp_project) }

    it 'updates a project' do
      put :update, id: project.id, sp_project: {name: 'Foobar10'}
      expect(project.reload.name).to eq('Foobar10')
    end

    it "doesn't throw an exception if you add spaces to the project name" do
      put :update, id: project.id, sp_project: {name: project.name + ' '}
      expect(assigns(:project).name).to eq(project.name)
    end
  end

  context '#create' do
    it 'creates a project' do
      expect {
        post :create, sp_project: build(:sp_project).attributes
      }.to change(SpProject, :count).by(1)
    end
  end

  context '#download' do
    it 'should download csv' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      year = Date.today.year
      project = create(:sp_project,
                       year: year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 1.month.ago,
      )

      # pd
      pd_person = create(:person)
      pd_staff = create(:sp_staff, person: pd_person, year: year, type: 'PD', sp_project: project)

      # staff
      staff_person = create(:person)
      staff_staff = create(:sp_staff, person: staff_person, year: year, type: 'Staff', sp_project: project)

      # volunteers
      vol_person = create(:person)
      vol_staff = create(:sp_staff, person: vol_person, year: year, type: 'Volunteer', sp_project: project)

      # accepted applicant
      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           year: year,
                           status: 'accepted_as_participant'
      )

      # accepted accepted_as_student_staff
      applicant2 = create(:person)
      application2 = create(:sp_application,
                           person_id: applicant2.id,
                           project_id: project.id,
                           year: year,
                           status: 'accepted_as_student_staff'
      )

      get :download, id: project.id, year: year
      expect(response.status).to eq(200)
    end
  end

  context '#sos' do
    it 'should download csv' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      year = SpApplication.year
      project = create(:sp_project,
                       country: 'United States',
                       state: 'MN',
                       year: year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 1.month.ago,
                       operating_business_unit: 'obu',
                       operating_operating_unit: 'oou',
                       operating_department: 'od',
                       project_status: 'open',
                       pd_close_start_date: 1.month.from_now
      )

      # pd
      pd_person = create(:person)
      pd_staff = create(:sp_staff, person: pd_person, year: year, type: 'PD', sp_project: project)

      # staff
      staff_person = create(:person)
      staff_staff = create(:sp_staff, person: staff_person, year: year, type: 'Staff', sp_project: project)

      # volunteers
      vol_person = create(:person)
      vol_staff = create(:sp_staff, person: vol_person, year: year, type: 'Volunteer', sp_project: project)

      # accepted applicant
      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           year: year,
                           status: 'accepted_as_participant'
      )

      # accepted accepted_as_student_staff
      applicant2 = create(:person)
      application2 = create(:sp_application,
                           person_id: applicant2.id,
                           project_id: project.id,
                           year: year,
                           status: 'accepted_as_student_staff'
      )

      post :sos, start: 2.weeks.from_now, end: 6.weeks.from_now
      expect(response.status).to eq(200)
    end
  end

  context '#dashboar' do
    it 'should redirect to dashboard_path' do
      expect(get(:dashboard)).to redirect_to('/admin/projects')
    end
  end

  context '#close' do
    it 'should close a project' do
      project = create(:sp_project)
      request.env["HTTP_REFERER"] = '/'
      post :close, id: project.id
      project.reload
      expect(project.closed?).to be(true)
    end
  end

  context '#open' do
    it 'should open a project' do
      project = create(:sp_project)
      project.close!
      request.env["HTTP_REFERER"] = '/'
      post :open, id: project.id
      project.reload
      expect(project.open?).to be(true)
    end
    it 'should not open an invalid project' do
      project = create(:sp_project)
      project.close!
      project.update_column(:name, nil)
      request.env["HTTP_REFERER"] = '/'
      expect(post(:open, id: project.id)).to redirect_to(edit_admin_project_path(project))
      project.reload
      expect(project.open?).to be(false)
      expect(flash[:notice]).to match(/update all necessary fields/)
    end
  end

  context '#new' do
    it 'should make a new project' do
      post :new
      expect(assigns(:project))
    end
  end

  context '#email' do
    before(:each) do
      @project = create(:sp_project)
      pd = create(:sp_staff, year: @project.year, sp_project: @project, type: 'PD')
      pd = create(:sp_staff, year: @project.year, sp_project: @project, type: 'APD')
      pd = create(:sp_staff, year: @project.year, sp_project: @project, type: 'OPD')

      # accepted applicant
      @applicant = create(:person)
      create(:fe_email_address, person_id: @applicant.id)
      @application = create(:sp_application,
                           person_id: @applicant.id,
                           project_id: @project.id,
                           year: @project.year,
                           status: 'accepted_as_participant'
      )
    end

    it 'should run' do
      get :email, id: @project.id
    end

    it 'should run group men_staff_and_interns' do
      get :email, id: @project.id, group: 'men_staff_and_interns'
    end
    
    it 'should run group women_staff_and_interns' do
      get :email, id: @project.id, group: 'women_staff_and_interns'
    end

    it 'should run including parents' do
      @project = create(:sp_project, primary_partner: "MK2MK")
      get :email, id: @project.id
    end
  end

  context '#sos_exceptions' do
    it 'should render' do
      year = SpApplication.year
      project = create(:sp_project,
                       country: 'United States',
                       state: 'MN',
                       year: year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 1.month.ago,
                       operating_business_unit: 'obu',
                       operating_operating_unit: 'oou',
                       operating_department: 'od',
                       project_status: 'open',
                       pd_close_start_date: 1.month.from_now
      )

      # accepted applicant
      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           year: year,
                           status: 'accepted_as_participant',
                           start_date: Date.new(year, 1, 1),
                           end_date: Date.new(year, 2, 1)
      )

      # accepted accepted_as_student_staff
      applicant2 = create(:person)
      application2 = create(:sp_application,
                           person_id: applicant2.id,
                           project_id: project.id,
                           year: year,
                           status: 'accepted_as_student_staff',
                           start_date: Date.new(year, 1, 1),
                           end_date: Date.new(year, 2, 1)
      )

      get :sos_exceptions
      expect(response.status).to eq(200)
    end
  end
end
