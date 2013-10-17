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
end
