require 'spec_helper'

describe SpDonationServices do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_director = create(:sp_director, person: @person, user: @user)
    @sp_donation_services = create(:sp_donation_services)
  end
  
  it "should be allowed to upload ds" do
    response = @sp_donation_services.send(:can_upload_ds?)
    response.should be true
  end
  
  it "should be allowed to search" do
    response = @sp_donation_services.send(:can_search?)
    response.should be true
  end
  
  it "should be allowed to view the dashboard" do
    response = @sp_donation_services.send(:can_see_dashboard?)
    response.should be true
  end
  
  it "should return an array ['1=1'] if the 'scope' when no partner specified" do
    response = @sp_donation_services.send(:scope)
    response.should == ['1=1']
  end
  
  it "should return an array if the 'scope' when a partner is specified" do
    partner = double(:person)
    response = @sp_donation_services.send(:scope, partner)
    response.should_not be nil
  end
  
  it "should return a string 'Donation Services' when asking for its role" do
    response = @sp_donation_services.send(:role)
    response.should == 'Donation Services'
  end
end