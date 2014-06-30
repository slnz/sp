require 'spec_helper'

describe SpGeneralStaff do
  before(:each) do
    @person = create(:person)
    @user = create(:sp_user, person: @person)
    @sp_general_staff = create(:sp_general_staff, person: @person)
  end
  
  it "should be allowed to search" do
    response = @sp_general_staff.send(:can_search?)
    expect(response).to be_truthy
  end
  
  it "should return a string 'General Staff' when asking for its role" do
    response = @sp_general_staff.send(:role)
    expect(response).to eq 'General Staff'
  end
end