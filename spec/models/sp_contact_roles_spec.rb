require 'spec_helper'

describe SpContactRoles do
  describe "when getting the available roles" do
    it "should return an array of roles" do
      SpContactRoles.all.should_not be nil
    end
  end
end