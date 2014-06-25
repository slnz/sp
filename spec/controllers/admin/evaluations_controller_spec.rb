require 'spec_helper'

describe Admin::EvaluationsController do
  let(:user) { create(:user) }
  let(:application) { create(:sp_application, project: create(:sp_project), person: create(:person)) }
  let(:evaluation) { create(:sp_evaluation, sp_application: application) }
  let(:project) { create(:sp_project) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#print' do
    it 'shows a printable view of an evaluation' do
      get :print, id: evaluation.id
      expect(response).to render_template('print')
    end
  end

  context '#update' do
    it "ignores attempts to double transition a state" do
      # This is usually caused by a double click
      create(:email_template, name: 'Application Moved')
      application.update_column(:status, 'accepted_as_participant')
      put :update, "id" => evaluation.id, "application_id" => application.id, "event" => "accept_as_participant",
                   "application" => {
                      "project_id" => project.id
                    },
                    "evaluation" => {
                      "authority" => "false",
                      "bad_evangelism" => "false",
                      "charismatic" => "false",
                      "comments" => nil,
                      "drugs" => "false",
                      "eating" => "false",
                      "morals" => "false"
                    }

      expect(assigns(:application).project).to eq(project)
    end
  end

  context '#evaluate' do
    it 'evaluates projects -- applicant is male' do
      project = create(:sp_project)
      project.update(project_status: 'open', use_provided_application: 1, )

      project_base = SpProject.open.uses_application.order(:name)

      applicant = create(:person)
      applicant.update(gender: 1)

      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')
      evaluation = create(:sp_evaluation, application_id: application.id)

      get :evaluate, application_id: application.id
      expect(assigns(:projects)).to eq(project_base.not_full_men)
    end
  end

  context '#page' do
    it 'applicants answers' do
      # what chokes up the next page on line 24?
      # create a page or two
      # create an answer_sheet

      get :page
    end
  end
end
