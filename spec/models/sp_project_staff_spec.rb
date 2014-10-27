require 'spec_helper'

describe SpProjectStaff do
  context "#role" do
    it "should return a string" do
      s = SpProjectStaff.new
      expect(s.role.class).to be String
    end
  end
end
