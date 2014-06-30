require 'spec_helper'

describe SpDirector do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_director = create(:sp_director, person: @person, user: @user)
  end
  
  it "is allowed to search" do
    response = @sp_director.send(:can_search?)
    expect(response).to be_truthy
  end
  
  it "is allowed to add an applicant" do
    response = @sp_director.send(:can_add_applicant?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit an applicant's info" do
    response = @sp_director.send(:can_edit_applicant_info?)
    expect(response).to be_truthy
  end
  
  it "is allowed to evaluate an application" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    
    sample = Array.new
    sample << project
    
    expect(@sp_director.person).to receive(:current_staffed_projects).and_return(sample)
    response = @sp_director.send(:can_evaluate_applicant?, application)
    expect(response).to be_truthy
  end
  
  it "is not allowed to evaluate an unknown applicant" do
    response = @sp_director.send(:can_evaluate_applicant?)
    expect(response).to be_falsey
  end
  
  it "is not allowed to see the dashboard if there is no directed projects" do
    sample = Array.new
    expect(@sp_director.person).to receive(:directed_projects).and_return(sample)
    response = @sp_director.send(:can_see_dashboard?)
    expect(response).to be_falsey
  end
  
  it "is allowed to see the dashboard if there is are directed projects" do
    project = create(:sp_project)
    create(:sp_application, person: @person, project: project)
    sample = Array.new
    sample << project
    sample << project
    expect(@sp_director.person).to receive(:directed_projects).and_return(sample)
    response = @sp_director.send(:can_see_dashboard?)
    expect(response).to be_truthy
  end
  
  it "is allowed to see the roster" do
    response = @sp_director.send(:can_see_roster?)
    expect(response).to be_truthy
  end
  
  it "is allowed to see the pd_reports" do
    response = @sp_director.send(:can_see_pd_reports?)
    expect(response).to be_truthy
  end
  
  it "returns an array if the 'scope' function is called" do
    response = @sp_director.send(:scope)
    expect(response).not_to be nil
  end
  
  it "returns the default heading" do
    response = @sp_director.send(:heading)
    expect(response).to eq "My Projects"
  end
  
  it "returns a string 'Director' when asking for its role" do
    response = @sp_director.send(:role)
    expect(response).to eq 'Director'
  end
end