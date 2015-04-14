require 'spec_helper'

describe CampusesController do
  context '#search' do
    it 'should set the current persons state (?)' do
      user = create(:user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      el = create(:fe_school_picker)
      project = create(:sp_project)
      applicant = create(:person, user: user)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready')

      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Btype%5D=HighSchool')
        .to_return(status: 200, body: '{"target_areas":[{"name":"High School", "state": "High School State"}]}', headers: {})

      stub_request(:get, 'https://infobase.uscm.org/api/v1/target_areas?filters%5Bstate%5D=MN&filters%5Btype%5D=College')
        .to_return(status: 200, body: '{"target_areas":[{"name":"Campus Name", "state": "Campus State"}]}', headers: {})

      post :search, state: 'MN', id: application.id, dom_id: el.dom_id(el), format: 'js'
      applicant.reload
      expect(applicant.universityState).to eq('MN')
    end
  end
end
