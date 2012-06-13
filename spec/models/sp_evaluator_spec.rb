require 'spec_helper'

describe SpEvaluator do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_evaluator = create(:sp_evaluator, person: @person, user: @user)
  end
  
  it "should not be allowed to change project status" do
    response = @sp_evaluator.send(:can_change_project_status?)
    response.should be false
  end
  
  it "should not be allowed to change it own information" do
    response = @sp_evaluator.send(:can_change_self?)
    response.should be false
  end
  
  it "should not be allowed to add a user" do
    response = @sp_evaluator.send(:can_add_user?)
    response.should be false
  end
  
  it "should be allowed to search" do
    response = @sp_evaluator.send(:can_search?)
    response.should be true
  end
  
  it "should not be allowed to view other regions" do
    response = @sp_evaluator.send(:can_see_other_regions?)
    response.should be false
  end
  
  it "should be allowed to evaluate an application" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    
    sample = Array.new
    sample << project
    
    @sp_evaluator.person.should_receive(:current_staffed_projects).and_return(sample)
    response = @sp_evaluator.send(:can_evaluate_applicant?, application)
    response.should be true
  end
  
  it "should be allowed to evaluate an unknown application" do
    response = @sp_evaluator.send(:can_evaluate_applicant?)
    response.should be false
  end
  
  it "should be allowed to view the roster" do
    response = @sp_evaluator.send(:can_see_roster?)
    response.should be true
  end
  
  it "should return a string region when 'creatable_user_types' function is called" do
    @sp_evaluator.should_receive(:creatable_user_types_array).with(nil).and_return([])
    response = @sp_evaluator.send(:creatable_user_types)
    response.should == []
  end
  
  it "should return a string region when the region function is called" do
    @sp_evaluator.user.person.should_receive(:region).and_return('Region')
    response = @sp_evaluator.send(:region)
    response.should == 'Region'
  end
  
  it "should return a string 'Evaluator' when asking for its role" do
    response = @sp_evaluator.send(:role)
    response.should == 'Evaluator'
  end
end