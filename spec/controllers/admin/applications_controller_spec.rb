require 'spec_helper'

describe Admin::ApplicationsController do
  let(:user) { create(:user) }

  before do
    create(:sp_national_coordinator, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#search' do
    it 'sets up a search form' do
      stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters[country]=USA").
        to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})
      stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
        to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

      get 'search'
      expect(response).to render_template('search')
    end
  end

  context '#search_results' do
    it 'returns results' do
      stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters[country]=USA").
        to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})
      stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
        to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

      application = create(:sp_application, project_id: 1)
      post 'search_results', preference: 1
      expect(assigns(:applications).first).to eq(application)
    end

    it 'should set all the filters' do
       stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
         with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer 7e78285443a4f2d8c7b88fb2a3e449a4', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

      get :search,
        first_name: 'fn', 
        last_name: 'ln',
        school: 'UW',
        team: 'team',
        region: 'GL',
        state: 'MN',
        designation: 'DN',
        project_type: 'PT',
        status: 'open',
        year: SpApplication.year
    end
  end

  context '#donations' do
    it 'displays donations for the applicant' do
      application = create(:sp_application, project: create(:sp_project), person: create(:person))
      get 'donations', id: application.id
      expect(response).to render_template('donations')
    end
  end

  context '#waive_fee' do
    it "waves an applicant's fee" do
      request.env["HTTP_REFERER"] = 'foo'
      application = create(:sp_application)

      get 'waive_fee', id: application.id
      expect(application.reload.has_paid?).to eq(true)
    end
  end
end
