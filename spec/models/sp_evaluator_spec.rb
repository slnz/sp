require 'spec_helper'

describe SpEvaluator do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_evaluator = create(:sp_evaluator, person: @person, user: @user)
  end
  
  it "is not be allowed to change project status" do
    response = @sp_evaluator.send(:can_change_project_status?)
    expect(response).to be_falsey
  end
  
  it "is not be allowed to change it own information" do
    response = @sp_evaluator.send(:can_change_self?)
    expect(response).to be_falsey
  end
  
  it "is not be allowed to add a user" do
    response = @sp_evaluator.send(:can_add_user?)
    expect(response).to be_falsey
  end
  
  it "is allowed to search" do
    response = @sp_evaluator.send(:can_search?)
    expect(response).to be_truthy
  end
  
  it "is not be allowed to view other regions" do
    response = @sp_evaluator.send(:can_see_other_regions?)
    expect(response).to be_falsey
  end
  
  it "is allowed to evaluate an application" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    
    sample = Array.new
    sample << project
    
    expect(@sp_evaluator.person).to receive(:current_staffed_projects).and_return(sample)
    response = @sp_evaluator.send(:can_evaluate_applicant?, application)
    expect(response).to be_truthy
  end
  
  it "is allowed to evaluate an unknown application" do
    response = @sp_evaluator.send(:can_evaluate_applicant?)
    expect(response).to be_falsey
  end
  
  it "is allowed to view the roster" do
    response = @sp_evaluator.send(:can_see_roster?)
    expect(response).to be_truthy
  end
  
  it "returns a string region when 'creatable_user_types' function is called" do
    expect(@sp_evaluator).to receive(:creatable_user_types_array).with(nil).and_return([])
    response = @sp_evaluator.send(:creatable_user_types)
    expect(response).to eq []
  end
  
  it "returns a string region when the region function is called" do
    expect(@sp_evaluator.user.person).to receive(:region).and_return('Region')
    response = @sp_evaluator.send(:region)
    expect(response).to eq 'Region'
  end
  
  it "returns a string 'Evaluator' when asking for its role" do
    response = @sp_evaluator.send(:role)
    expect(response).to eq 'Evaluator'
  end
end