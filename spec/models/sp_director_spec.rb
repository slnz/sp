require 'spec_helper'

describe SpDirector do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_director = create(:sp_director, person: @person, user: @user)
  end
  
  it "should be allowed to search" do
    response = @sp_director.send(:can_search?)
    response.should be true
  end
  
  it "should be allowed to add an applicant" do
    response = @sp_director.send(:can_add_applicant?)
    response.should be true
  end
  
  it "should be allowed to edit an applicant's info" do
    response = @sp_director.send(:can_edit_applicant_info?)
    response.should be true
  end
  
  it "should be allowed to evaluate an application" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    
    sample = Array.new
    sample << project
    
    @sp_director.person.should_receive(:current_staffed_projects).and_return(sample)
    response = @sp_director.send(:can_evaluate_applicant?, application)
    response.should be true
  end
  
  it "should not be allowed to evaluate an unknown applicant" do
    response = @sp_director.send(:can_evaluate_applicant?)
    response.should be false
  end
  
  it "should not be allowed to see the dashboard if there is no directed projects" do
    sample = Array.new
    @sp_director.person.should_receive(:directed_projects).and_return(sample)
    response = @sp_director.send(:can_see_dashboard?)
    response.should be false
  end
  
  it "should be allowed to see the dashboard if there is are directed projects" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    sample = Array.new
    sample << project
    sample << project
    @sp_director.person.should_receive(:directed_projects).and_return(sample)
    response = @sp_director.send(:can_see_dashboard?)
    response.should be true
  end
  
  it "should be allowed to see the roster" do
    response = @sp_director.send(:can_see_roster?)
    response.should be true
  end
  
  it "should be allowed to see the pd_reports" do
    response = @sp_director.send(:can_see_pd_reports?)
    response.should be true
  end
  
  it "should return an array if the 'scope' function is called" do
    response = @sp_director.send(:scope)
    response.should_not be nil
  end
  
  it "should return the default heading" do
    response = @sp_director.send(:heading)
    response.should == "My Projects"
  end
  
  it "should return a string 'Director' when asking for its role" do
    response = @sp_director.send(:role)
    response.should == 'Director'
  end
end