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
      person.update_column(:personID, 123456)
      @application = create(:sp_application, person: person, project: create(:sp_project), year: SpApplication.year)
    end

    it 'receives a file from DSG and assigns designation numbers' do
      post 'upload', upload: {upload: fixture_file_upload('/donation_services_upload.txt', 'text/csv')}
      expect(response).to render_template('upload')
      expect(assigns(:error_messages)).to eq([])
      expect(@application.reload.designation_number(SpApplication.year)).to eq('005508771')
    end
  end
end
