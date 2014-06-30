require 'spec_helper'

describe SpContactRoles do
  describe "when getting the available roles" do
    it "should return an array of roles" do
      expect(SpContactRoles.all).not_to be_nil
    end
  end
end