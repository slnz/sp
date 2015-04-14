require 'spec_helper'

describe Admin::ProjectsController do
  let(:user) { create(:user, person: create(:person)) }
  let(:person) { create(:person) }

  before do
    @sp_user = create(:sp_national_coordinator, user: user, person: person)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#index' do
    it 'lists open projects' do
      get :index
      expect(response).to render_template('index')
    end

    it 'should use all of set_up_filters' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

      get :index, partners: ['US Campus', 'Non-USCM SPs', 'PRIMARY PARTNER'], search: 'search'
      expect(response).to render_template('index')
    end

    context 'SpProjectStaff and search_pd' do
      it 'should use all of set_up_filters' do
        stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

        @sp_user[:type] = 'SpProjectStaff'
        @sp_user.save!
        get :index, partners: ['US Campus', 'Non-USCM SPs', 'PRIMARY PARTNER'], search_pd: 'search_pd'
        expect(response).to render_template('index')
      end
    end

    context 'SpRegionalCoordinator and search_apd' do
      it 'should use all of set_up_filters' do
        stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

        @sp_user[:type] = 'SpRegionalCoordinator'
        @sp_user.save!
        get :index, partners: ['US Campus', 'Non-USCM SPs', 'PRIMARY PARTNER'], search_apd: 'search_apd'
        expect(response).to render_template('index')
      end
    end

    context 'SpNationalCoordinator and search_opd' do
      it 'should use all of set_up_filters' do
        stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

        @sp_user[:type] = 'SpNationalCoordinator'
        @sp_user.save!
        get :index, partners: ['US Campus', 'Non-USCM SPs', 'PRIMARY PARTNER'], search_opd: 'search_opd'
        expect(response).to render_template('index')
      end
    end

    context 'other user type' do
      it 'should use all of set_up_filters' do
        stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

        @sp_user[:type] = 'SpGeneralStaff'
        @sp_user.save!
        get :index, partners: ['US Campus', 'Non-USCM SPs', 'PRIMARY PARTNER'], search: 'search'
        expect(response).to render_template('index')
      end
    end
  end

  context '#show' do
    it 'shows project details' do
      project = create(:sp_project)
      pd_person = create(:person, isStaff: false)
      pd_staff = create(:sp_staff, person: pd_person, year: project.year, type: 'PD', sp_project: project)
      get :show, id: project.id
      expect(response).to render_template('show')
    end
  end

  context '#edit' do
    it 'shows project edit form' do
      get :edit, id: create(:sp_project).id
      expect(response).to render_template('edit')
    end
  end

  context '#destroy' do
    it 'deletes a project' do
      project = create(:sp_project)
      expect do
        delete :destroy, id: project.id
      end.to change(SpProject, :count).by(-1)
    end
  end

  context '#update' do
    let(:project) { create(:sp_project) }

    it 'updates a project while creating a new textfield/page' do
      put :update, id: project.id, sp_project: { name: 'Foobar10' }, questions: { '1' => { label: 'test' } }
      expect(project.reload.name).to eq('Foobar10')
    end

    it 'updates a project while updating an existing element' do
      e = Fe::TextField.create!(label: 'some_question')
      put :update, id: project.id, sp_project: { name: 'Foobar10' }, questions: { '1' => { id: e.id, label: 'test' } }
      expect(project.reload.name).to eq('Foobar10')
      e.reload
      expect(e.label).to eq('test')
    end

    it 'updates a project while destroying an existing question' do
      e = Fe::TextField.create!(label: 'some_question')
      put :update, id: project.id, sp_project: { name: 'Foobar10' }, questions: { '1' => { id: e.id } }
      expect(project.reload.name).to eq('Foobar10')
      expect(Fe::TextField.where(id: e.id).first).to be nil
    end

    it "doesn't throw an exception if you add spaces to the project name" do
      put :update, id: project.id, sp_project: { name: project.name + ' ' }
      expect(assigns(:project).name).to eq(project.name)
    end
  end

  context '#create' do
    it 'creates a project' do
      expect do
        post :create, sp_project: build(:sp_project).attributes
      end.to change(SpProject, :count).by(1)
    end

    it "creates render new if the project doesn't save" do
      attributes = build(:sp_project).attributes
      attributes.delete('name')
      stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))
      post :create, sp_project: attributes
      expect(response).to render_template(:new)
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
                       open_application_date: 1.month.ago
      )

      # pd
      pd_person = create(:person)
      pd_staff = create(:sp_staff, person: pd_person, year: year, type: 'PD', sp_project: project)

      # staff
      staff_person = create(:person)
      staff_address = create(:fe_address, person: staff_person, address_type: 'current')
      staff_staff = create(:sp_staff, person: staff_person, year: year, type: 'Staff', sp_project: project)

      # staff
      staff_person = create(:person)
      staff_address = create(:fe_address, person: staff_person, address_type: 'emergency1')
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

      stub_request(:get, 'http://maps.googleapis.com/maps/api/geocode/json?address=String,MN,United%20States&language=en&sensor=false')
        .to_return(status: 200, body: @geocode_body, headers: {})

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
      request.env['HTTP_REFERER'] = '/'
      post :close, id: project.id
      project.reload
      expect(project.closed?).to be(true)
    end
  end

  context '#open' do
    it 'should open a project' do
      project = create(:sp_project)
      project.close!
      request.env['HTTP_REFERER'] = '/'
      post :open, id: project.id
      project.reload
      expect(project.open?).to be(true)
    end
    it 'should not open an invalid project' do
      project = create(:sp_project)
      project.close!
      project.update_column(:name, nil)
      request.env['HTTP_REFERER'] = '/'
      expect(post(:open, id: project.id)).to redirect_to(edit_admin_project_path(project))
      project.reload
      expect(project.open?).to be(false)
      expect(flash[:notice]).to match(/update all necessary fields/)
    end
  end

  context '#new' do
    it 'should make a new project' do
      stub_request(:get, 'https://infobase.uscm.org/api/v1/regions')
        .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))
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
      @project = create(:sp_project, primary_partner: 'MK2MK')
      get :email, id: @project.id
    end
  end

  context '#sos_exceptions' do
    it 'should render' do
      year = SpApplication.year

      stub_request(:get, 'http://maps.googleapis.com/maps/api/geocode/json?address=String,MN,United%20States&language=en&sensor=false')
        .to_return(status: 200, body: @geocode_body, headers: {})

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

  context '#send_email' do
    it 'should send email successfully' do
      # include one invalid email to cover more code
      p = create(:sp_project)
      post :send_email, id: p.id, from: 'test@cru.org', to: '<a@b.com,c@d.com> A B, invalid@email:com'
    end
    it 'should handle a failed email send' do
      # include one invalid email to cover more code
      p = create(:sp_project)
      # ProjectMailer.stub(:team_email) { throw("Exception") }
      allow(ProjectMailer).to receive(:team_email) { throw('Exception') }
      post :send_email, id: p.id, from: 'test@cru.org', to: 'a@b.com,c@d.com,invalid@email:com'
    end
    it "should handle an email with a from address that doesn't end with @cru.org" do
      # include one invalid email to cover more code
      p = create(:sp_project)
      # ProjectMailer.stub(:team_email) { throw("Exception") }
      allow(ProjectMailer).to receive(:team_email) { throw('Exception') }
      request.env['HTTP_REFERER'] = '/admin'
      post :send_email, id: p.id, from: 'test@asdf.org', to: 'a@b.com,c@d.com,invalid@email:com'
      expect(flash[:notice]).to eq('You must specify a "From" address that ends with @cru.org')
      expect(response).to redirect_to('/admin')
    end
    it 'should handle no to address given' do
      # include one invalid email to cover more code
      p = create(:sp_project)
      # ProjectMailer.stub(:team_email) { throw("Exception") }
      allow(ProjectMailer).to receive(:team_email) { throw('Exception') }
      request.env['HTTP_REFERER'] = '/admin'
      post :send_email, id: p.id, from: 'test@cru.org', to: ''
      expect(flash[:notice]).to eq('You must specify a "To" address')
      expect(response).to redirect_to('/admin')
    end
  end
end
