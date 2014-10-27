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
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters[country]=USA&per_page=30000").
        to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})
      stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
        to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

      get 'search'
      expect(response).to render_template('search')
    end

    it 'should check permissions' do
      SpUser.where(ssm_id: user.id).first.update_column(:type, "SpUser")
      get 'search'
      expect redirect_to(no_admin_projects_path)
    end
  end

  context '#search_results' do
    it 'returns results' do
      stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters[country]=USA&per_page=30000").
        to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})
      stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
        to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

      application = create(:sp_application, project_id: 1)
      post 'search_results', preference: 1
      expect(assigns(:applications).first).to eq(application)
    end

    it 'should set all the filters' do
       stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
         to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

       stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bcountry%5D=USA&per_page=30000").
         to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})

       stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bteam_id%5D=team").
         to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})

       stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

       post :search_results,
         first_name: 'fn', 
         last_name: 'ln',
         school: 'UW',
         team: 'team',
         region: 'GL',
         state: 'MN',
         designation: 12345,
         project_type: 'PT',
         status: 'open',
         city: 'city',
         preference: 1,
         year: SpApplication.year
      expect(response.code).to eq("200")
    end

    it 'should set the other filters' do
       stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
         to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

       stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bcountry%5D=USA&per_page=30000").
         to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})

       stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bteam_id%5D=team").
         to_return(:status => 200, :body => '{"target_areas":[{"name":"UW"}]}', :headers => {})

       stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

       get :search_results,
         first_name: 'fn', 
         last_name: 'ln',
         school: 'UW',
         team: 'team',
         region: 'GL',
         state: 'MN',
         designation: 12345,
         project_type: 'US',
         status: 'open',
         year: SpApplication.year,
         page: 'all'
      expect(response.code).to eq("200")
    end

    it "should give a flash notice if there's no criteria" do
      stub_request(:get, "https://infobase.uscm.org/api/v1/teams?filters%5Blane%5D=FS").
        to_return(:status => 200, :body => '{"teams":[]}', :headers => {})

      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters[country]=USA&per_page=30000").
        to_return(:status => 200, :body => '{"target_areas":[]}', :headers => {})

      stub_request(:get, "https://infobase.uscm.org/api/v1/regions").
         to_return(:status => 200, :body => File.read(Rails.root.join('spec', 'fixtures', 'regions.txt')))

      get :search_results
      expect(flash[:notice]).to match(/You must use at least one search criteria/)
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

    it "checks permissions" do
      # make the user a regional coordinator instead of a national coordinator
      SpUser.where(ssm_id: user.id).first.update_column(:type, "SpRegionalCoordinator")

      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      request.env["HTTP_REFERER"] = 'foo'
      application = create(:sp_application)

      get 'waive_fee', id: application.id
      expect(flash[:error]).to match(/You don't have permission to waive fees/)
    end
  end

  context '#other_donations' do
    it "should work" do
      project = create(:sp_project)
      staff = create(:sp_staff, sp_project: project)
      application = create(:sp_application, project: project, person: create(:person))
      get :other_donations, id: application.id, staff_id: staff.id
      expect(response.code).to eq("200")
    end
  end
end
