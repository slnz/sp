require 'spec_helper'

describe Admin::ProjectsController do
  let(:user) { create(:user) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#index' do
    it 'lists open projects' do
      get :index
      expect(response).to render_template('index')
    end
  end

  context '#show' do
    it 'shows project details' do
      get :show, id: create(:sp_project).id
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
      expect {
        delete :destroy, id: project.id
      }.to change(SpProject, :count).by(-1)
    end
  end

  context '#update' do
    let(:project) { create(:sp_project) }

    it 'updates a project' do
      put :update, id: project.id, sp_project: {name: 'Foobar10'}
      expect(project.reload.name).to eq('Foobar10')
    end

    it "doesn't throw an exception if you add spaces to the project name" do
      put :update, id: project.id, sp_project: {name: project.name + ' '}
      expect(assigns(:project).name).to eq(project.name)
    end
  end

  context '#create' do
    it 'creates a project' do
      expect {
        post :create, sp_project: build(:sp_project).attributes
      }.to change(SpProject, :count).by(1)
    end
  end
end
