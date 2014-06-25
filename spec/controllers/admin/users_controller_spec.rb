require 'spec_helper'

describe Admin::UsersController do
  let(:user) { create(:user, person: create(:person)) }

  context '#index' do
    it 'lists all the sp users -- type national, render admin layout' do
      sp_user = create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :index, type: 'national'
      expect(assigns(:users)).to eq([sp_user])
      expect(response).to render_template(:admin)
    end

    it 'lists all the sp users -- type regional' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user = create(:user, person: create(:person))
      regional_coordinator = create(:sp_regional_coordinator, user: user, person_id: user.person.id)

      get :index, type: 'regional'
      expect(assigns(:users)).to eq([regional_coordinator])
      expect(response).to render_template(:_users)
    end

    it 'lists all the sp users -- type donation services' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user = create(:user, person: create(:person))
      donation_services = create(:sp_donation_services, user: user, person_id: user.person.id)

      get :index, type: 'donation_services'
      expect(assigns(:users)).to eq([donation_services])
      expect(response).to render_template(:_users)
    end

    it 'lists all the sp users -- type director' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user = create(:user, person: create(:person))
      director = create(:sp_director, user: user, person_id: user.person.id)

      get :index, type: 'directors'
      expect(assigns(:users)).to eq([director])
      expect(response).to render_template(:_users)
    end
  end

  context '#destroy' do
    it 'should destroy a user' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user = create(:user, person: create(:person))
      regional_coordinator = create(:sp_regional_coordinator, user: user, person_id: user.person.id)

      expect {
        delete :destroy, id: regional_coordinator.id
      }.to change(SpUser, :count).by(-1)

      expect(response).to redirect_to(admin_users_path)
    end
  end
end
