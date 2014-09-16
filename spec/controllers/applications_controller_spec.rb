require 'spec_helper'

describe ApplicationsController do
  context "closed" do
    it "should run" do
      user = create(:user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready'
      )

      get :closed, id: project.id
      expect(assigns(:project)).to eq(project)
    end
  end

  context '#index' do
    it 'should redirect to root' do
      user = create(:user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :index
      expect(redirect_to('/'))
    end
  end

  context '#apply' do
    it 'should redirect to closed for a closed project' do
      user = create(:user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed'
      )
      project.close!

      expect(get(:apply, p: project.id)).to redirect_to(closed_applications_path(id: project.id))
    end

    it 'a frozen application should redirect to the status page' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed'
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready'
      )

      expect(get(:apply, p: project.id)).to redirect_to(application_path(application))
    end

    it 'should resume an application' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      qs_as1 = create(:answer_sheet_question_sheet, answer_sheet: application, question_sheet: basic_info_qs)
      qs_as2 = create(:answer_sheet_question_sheet, answer_sheet: application, question_sheet: template_info_qs)

      get(:apply)
      r = get(:apply, p: project.id)
      expect(r.status).to eq(200)
    end

    it 'should fix the question sheets on an improperly configured application' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      get(:apply)
      expect(assigns(:application).question_sheets).to eq([basic_info_qs, template_info_qs])
    end

    it 'should send them to a page to decide what to do if they choose multiple projects' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      project2 = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      expect(get(:apply, p: project2.id)).to redirect_to(multiple_projects_application_path(application, :p => project2.id))
    end

    it 'should change the project when forced' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      project2 = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      create(:email_template, name: 'Application Moved')

      get(:apply, p: project2.id, force: 'true')
      expect(assigns(:application).project).to eq(project2)
    end

    it 'should create a new application' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      #create(:email_template, name: 'Application Moved')

      get(:apply, p: project.id)
      expect(assigns(:application).project).to eq(project)
    end

    it 'should create send you back to projects if no application and no project' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      #create(:email_template, name: 'Application Moved')

      expect(get(:apply, p: '123')).to redirect_to(projects_path)
    end
  end

  context '#multiple_projects' do
    it 'should render' do
      applicant = create(:person)
      user = create(:user, person: applicant)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      project2 = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      get :multiple_projects, id: application.id, p: project2.id
    end

    it 'should work for an sp_user with appropriate permissions viewing someone elses app' do
      applicant = create(:person)
      user = create(:user, person: applicant)

      logged_in_person = create(:person)
      logged_in_user = create(:user, person: logged_in_person)
      sp_user = create(:sp_national_coordinator, ssm_id: logged_in_user.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = logged_in_user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      project2 = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      get :multiple_projects, id: application.id, p: project2.id
    end
  end

  context '#edit' do
    it 'should render' do
      applicant = create(:person)
      user = create(:user, person: applicant)

      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      basic_info_qs = create(:question_sheet, label: "basic_info_question_sheet")
      create(:page, question_sheet: basic_info_qs)
      template_info_qs = create(:question_sheet, label: "template_question_sheet")
      create(:page, question_sheet: template_info_qs)

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: 1.month.from_now,
                       end_date: 2.months.from_now,
                       open_application_date: 30.days.ago,
                       use_provided_application: true,
                       project_status: 'closed',
                       basic_info_question_sheet: basic_info_qs,
                       template_question_sheet: template_info_qs
      )

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'started'
      )

      qs_as1 = create(:answer_sheet_question_sheet, answer_sheet: application, question_sheet: basic_info_qs)
      qs_as2 = create(:answer_sheet_question_sheet, answer_sheet: application, question_sheet: template_info_qs)

      get :edit, id: application.id
    end
  end 
end
