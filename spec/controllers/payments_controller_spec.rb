require 'spec_helper'

describe PaymentsController do
  let(:user) { create(:user) }
  let(:person) { create(:person, user: user) }
  let(:application) { create(:sp_application, person: person)}

  before do
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

  context '#create' do
    it 'Displays an error if the user tries to submit a second payment' do
      create(:payment, application: application)

      xhr :post, :create, application_id: application.id, "payment" => {
        "address" => nil,
        "card_number" => nil,
        "card_type" => nil,
        "city" => nil,
        "expiration_month" => nil,
        "expiration_year" => nil,
        "first_name" => nil,
        "last_name" => nil,
        "security_code" => nil,
        "staff_first" => nil,
        "staff_last" => nil,
        "state" => nil,
        "zip" => nil
      }

      expect(assigns(:payment).errors.count).to eq 1
    end
  end
end