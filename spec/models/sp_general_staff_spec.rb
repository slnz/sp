require 'spec_helper'

describe SpGeneralStaff do
  before(:each) do
    @person = create(:person)
    @user = create(:sp_user, person: @person)
    @sp_general_staff = create(:sp_general_staff, person: @person)
  end
  
  it "should be allowed to search" do
    response = @sp_general_staff.send(:can_search?)
    response.should be true
  end
  
  it "should return a string 'General Staff' when asking for its role" do
    response = @sp_general_staff.send(:role)
    response.should == 'General Staff'
  end
end