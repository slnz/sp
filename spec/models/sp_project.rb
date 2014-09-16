require 'spec_helper'

describe SpProject do
  before(:each) do
  end
  
  context "end_date_range" do
    it "should valiate start date is before end date" do
      project = SpProject.new
      project.start_date = 1.month.from_now
      project.end_date = 1.week.from_now
      project.valid?
      expect(project.errors[:base]).to include("goSP.com tab: Student Start Date must be before Student End Date")
    end
    it "should valiate pd start date is pd before end date" do
      project = SpProject.new
      project.pd_start_date = 1.month.from_now
      project.pd_end_date = 1.week.from_now
      project.valid?
      expect(project.errors[:base]).to include("Risk Management tab: PD Start Date must be before PD End Date")
    end
  end
end
