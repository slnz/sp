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

      get :search
      # BAD SPEC!!!
      # i expect some sort of redirection to happen here like to /admin/applications/search
      # i can't and shouldn't stub super, however super goes to parent class for search method
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

      user_for_sp_staff = create(:user, person: create(:person))
      sp_staff = create(:sp_regional_coordinator, user: user_for_sp_staff, person_id: user_for_sp_staff.person.id)

      SpUser.delete_all(:person_id => sp_staff.person.id)

      xhr :get, :create, type: 'national', person_id: sp_staff.person.id
      expect(assigns(:user)).to eq(SpNationalCoordinator.create!(person_id: sp_staff.person.id, ssm_id: sp_staff.ssm_id, created_by_id: session[:user_id]))
    end
  end

  context '#check_access' do
    it 'verifies sp user can add user -- w/ add rights' do
      sp_user = create(:sp_national_coordinator, user: user, person_id: user.person.id)
      expect(sp_user.can_add_user?).to eq(true)
    end

    it 'verifies sp user can add user -- w/o add rights' do
      sp_user = create(:sp_regional_coordinator, user: user, person_id: user.person.id)
      expect(sp_user.can_add_user?).to eq(false)
    end
  end
end
