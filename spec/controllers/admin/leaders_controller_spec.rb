require 'spec_helper'

describe Admin::LeadersController do
  let(:user) { create(:user) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#new' do
    it 'renders a form to add a new leader' do
      xhr :get, :new, name: 'John Doe'
      expect(response).to render_template('new')
    end
  end

  context '#create' do
    let(:project) { create(:sp_project) }
    let(:person) { create(:person) }

    it 'adds a pd to a project' do
      xhr :post, :create, project_id: project.id, person_id: person.id, leader: 'pd'
      expect(project.pd).to eq(person)
    end

    it 'adds a kid to a project' do
      xhr :post, :create, project_id: project.id, person_id: person.id, leader: 'kid'
      expect(project.kids).to include(person)
    end
  end

  context '#destroy' do
    let(:project) { create(:sp_project) }
    let(:person) { create(:person) }

    it 'removes a leader from a project' do
      project.sp_staff.create(:type => 'Kid', year: project.year, person_id: person.id)
      expect {
        xhr :delete, :destroy, id: project.id, person_id: person.id, leader: 'kid'
      }.to change(project.sp_staff, :count).by(-1)
    end
  end

  context '#search' do
    it 'searches for a person to add as a leader' do
      p = create(:person, firstName: 'John', last_name: 'Doe')
      xhr :get, :search, name: 'John Doe'
      expect(assigns(:people)).to include(p)
    end
  end

  context '#add_person' do
    let(:project) { create(:sp_project) }

    it 'creates a new person' do
      expect {
        xhr :post, :add_person, project_id: project.id, leader: 'pd', person: {firstName: 'Foo', lastName: 'bar', gender: '1', current_address_attributes: {email: 'somewhere@foo.com', home_phone: '555-555-5555', address_type: 'current'}}
        expect(assigns(:errors)).to be_nil
        expect(response).to render_template('create')
      }.to change(Person, :count)
    end
  end
end
