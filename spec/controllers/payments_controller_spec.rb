require 'spec_helper'

describe Fe::PaymentsController do
  let(:user) { create(:user) }
  let(:person) { create(:person, user: user) }
  let(:application) { create(:sp_application, person: person)}

  before do
    session[:cas_user] = 'foo@example.com'
    session[:user_id] = user.id
  end

=begin
  # TODO move stuff
  context '#edit' do
    it 'should allow an applicant to edit the reference' do
      person = Fe::Person.new is_staff: false
      allow_any_instance_of(Fe::PaymentsController).to receive(:current_person).and_return(person)
      payment = FactoryGirl.create(:payment, payment_type: 'Staff', payment_account_no: '12345')
      application = FactoryGirl.create(:application)
      get :edit, id: payment.id, application_id: application.id
    end
  end
=end

  context '#create' do
    it 'Displays an error if the user tries to submit a second payment' do
      create(:payment, application: application)

      xhr :post, :create, application_id: application.id, "payment" => {"address" => nil}

      expect(assigns(:payment).errors.count).to eq 1
    end

    it "Displays an error if we can't find the staff person who is supposed to pay" do
      xhr :post, :create, application_id: application.id, "payment" => {
        "payment_account_no" => '32451234',
        "payment_type" => "Staff",
        "staff_first" => "kazu",
        "staff_last" => "kurihara"
      }

      expect(assigns(:payment).errors.count).to eq 1
    end
    it "Displays an error if we don't have an email on file for the staff who is supposed to pay" do
      staff = create(:staff, accountNo: '000991063')

      xhr :post, :create, application_id: application.id, "payment" => {
        "payment_account_no" => staff.accountNo,
        "payment_type" => "Staff",
        "staff_first" => "kazu",
        "staff_last" => "kurihara"
      }

      expect(assigns(:payment).errors.count).to eq 1
    end
  end
end
