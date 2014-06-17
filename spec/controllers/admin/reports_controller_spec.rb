require 'spec_helper'

describe Admin::ReportsController do
  let(:user) { create(:user) }

  context '#show' do
    it 'determines if you are a director' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :show

      if SpUser.find_by_ssm_id(session[:user_id]).type == 'SpDirector'
        response.should redirect_to(action: :director)
      end
    end
  end
end
