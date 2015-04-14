require 'spec_helper'

describe Admin::DonationServicesController do
  let(:user) { create(:user) }

  before do
    create(:sp_donation_services, user: user)
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#index' do
    it 'displays a link to download' do
      get 'index'
      expect(response).to render_template('index')
    end
  end

  context '#upload' do
    let(:person) { create(:person, user: user) }
    before do
      person.update_column(:id, 123_456)
      @application = create(:sp_application, person: person, project: create(:sp_project), year: SpApplication.year,
                                             status: 'accepted_as_participant')
    end

    it 'receives a file from DSG and assigns designation numbers' do
      post 'upload', upload: { upload: fixture_file_upload('/donation_services_upload.txt', 'text/csv') }
      expect(response).to render_template('upload')
      expect(assigns(:error_messages)).to eq([])
      expect(@application.reload.designation_number(SpApplication.year)).to eq('005508771')
    end

    it 'assigns the designation number to an accepted application' do
      @application.update_column(:status, 'withdrawn')
      @application2 = create(:sp_application, person: person, project: create(:sp_project), year: SpApplication.year,
                                              status: 'started')
      @application3 = create(:sp_application, person: person, project: create(:sp_project), year: SpApplication.year,
                                              status: 'accepted_as_participant')
      post 'upload', upload: { upload: fixture_file_upload('/donation_services_upload.txt', 'text/csv') }
      expect(response).to render_template('upload')
      expect(assigns(:error_messages)).to eq([])
      expect(@application.reload.designation_number(SpApplication.year)).to be_nil
      expect(@application2.reload.designation_number(SpApplication.year)).to be_nil
      expect(@application3.reload.designation_number(SpApplication.year)).to eq('005508771')
    end
  end
end
