require 'spec_helper'

describe Admin::UsersController do
  let(:user) { create(:user, person: create(:person)) }

  context '#index' do
    it '' do
      create(:sp_director, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :index, type: 'national'
    end
  end
end
