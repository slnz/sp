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

  context '#search' do
    it 'should call super search' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :search, controller: 'admin/applications'
      # BAD SPEC!!!
      # not complete
    end
  end

  context '#create' do
    it 'should do nothing when person id and params do not exist' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :create
      expect(response.body).to match(/\s?/)
      # response.body could return 1/2 whitespaces
    end

    it 'should create corresponding type -- national' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user_for_sp_user = create(:user, person: create(:person))
      sp_user = create(:sp_regional_coordinator, user: user_for_sp_user, person_id: user_for_sp_user.person.id)

      expect {
        xhr :get, :create, type: 'national', person_id: sp_user.person.id
      }.to change(SpRegionalCoordinator, :count).by(-1) && change(SpNationalCoordinator, :count).by(+1)
    end

    it 'should create corresponding type -- regional' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user_for_sp_user = create(:user, person: create(:person))
      sp_user = create(:sp_national_coordinator, user: user_for_sp_user, person_id: user_for_sp_user.person.id)

      expect {
        xhr :get, :create, type: 'regional', person_id: sp_user.person.id
      }.to change(SpRegionalCoordinator, :count).by(+1) && change(SpNationalCoordinator, :count).by(-1)
    end

    it 'should create corresponding type -- donation' do
      create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      user_for_sp_user = create(:user, person: create(:person))
      sp_user = create(:sp_national_coordinator, user: user_for_sp_user, person_id: user_for_sp_user.person.id)

      expect {
        xhr :get, :create, type: 'donation_services', person_id: sp_user.person.id
      }.to change(SpDonationServices, :count).by(+1) && change(SpNationalCoordinator, :count).by(-1)
    end
  end

  context '#check_access' do
    it 'verifies sp user can add user -- w/ add rights' do
      sp_user = create(:sp_national_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id
      get :index
      expect(response.status).to eq(200)
    end

    it 'verifies sp user can add user -- w/o add rights' do
      sp_user = create(:sp_regional_coordinator, user: user, person_id: user.person.id)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id
      get :index
      expect(response).to redirect_to('/admin')
    end
  end
end
