require 'spec_helper'

describe SpDonationServices do
  let(:person) { create(:person) }
  let(:user) { create(:user, person: person) }
  let(:user2) { create(:user, person: create(:person)) }
  let(:sp_user) { create(:sp_user, person: person) }
  let(:sp_director) { create(:sp_director, person: person, user: user) }
  let(:sp_donation_services) { create(:sp_donation_services, user: user2) }

  it "should be allowed to upload ds" do
    response = sp_donation_services.send(:can_upload_ds?)
    expect(response).to be_truthy
  end
  
  it "should be allowed to search" do
    response = sp_donation_services.send(:can_search?)
    expect(response).to be_truthy
  end
  
  it "should be allowed to view the dashboard" do
    response = sp_donation_services.send(:can_see_dashboard?)
    expect(response).to be_truthy
  end
  
  it "should return an array ['1=1'] if the 'scope' when no partner specified" do
    response = sp_donation_services.send(:scope)
    expect(response).to eq ['1=1']
  end
  
  it "should return an array if the 'scope' when a partner is specified" do
    partner = double(:person)
    response = sp_donation_services.send(:scope, partner)
    expect(response).not_to be_nil
  end
  
  it "should return a string 'Donation Services' when asking for its role" do
    response = sp_donation_services.send(:role)
    expect(response).to eq 'Donation Services'
  end
end