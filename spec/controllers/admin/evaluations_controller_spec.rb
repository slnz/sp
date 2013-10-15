require 'spec_helper'

describe Admin::EvaluationsController do
  let(:user) { create(:user) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#print' do
    it 'shows a printable view of an evaluation' do
      application = create(:sp_application, project: create(:sp_project), person: create(:person))
      evaluation = create(:sp_evaluation, sp_application: application)
      get :print, id: evaluation.id
      expect(response).to render_template('print')
    end
  end
end