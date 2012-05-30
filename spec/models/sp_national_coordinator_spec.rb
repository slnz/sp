require 'spec_helper'

describe SpNationalCoordinator do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_national_coordinator = create(:sp_national_coordinator, person: @person, user: @user)
  end
  
  it "should be allowed to delete a project" do
    response = @sp_national_coordinator.send(:can_delete_project?)
    response.should be true
  end
  
  it "should be allowed to change a project status" do
    response = @sp_national_coordinator.send(:can_change_project_status?)
    response.should be true
  end
  
  it "should be allowed to change its info" do
    response = @sp_national_coordinator.send(:can_change_self?)
    response.should be true
  end
  
  it "should be allowed to add a user" do
    response = @sp_national_coordinator.send(:can_add_user?)
    response.should be true
  end
  
  it "should be allowed to add an applicant" do
    response = @sp_national_coordinator.send(:can_add_applicant?)
    response.should be true
  end
  
  it "should be allowed to view other regions" do
    response = @sp_national_coordinator.send(:can_see_other_regions?)
    response.should be true
  end
  
  it "should be allowed to edit a project" do
    project = create(:sp_project)
    response = @sp_national_coordinator.send(:can_edit_project?, project)
    response.should be true
  end
  
  it "should be allowed to merge a project" do
    response = @sp_national_coordinator.send(:can_merge_projects?)
    response.should be true
  end
  
  it "should be allowed to su application" do
    response = @sp_national_coordinator.send(:can_su_application?)
    response.should be true
  end
  
  it "should be allowed to edit references" do
    response = @sp_national_coordinator.send(:can_edit_references?)
    response.should be true
  end
  
  it "should be allowed to edit a questionnaire" do
    response = @sp_national_coordinator.send(:can_edit_questionnaire?)
    response.should be true
  end
  
  it "should be allowed to edit payments" do
    response = @sp_national_coordinator.send(:can_edit_payments?)
    response.should be true
  end
  
  it "should be allowed to edit applicant's info" do
    response = @sp_national_coordinator.send(:can_edit_applicant_info?)
    response.should be true
  end
  
  it "should be allowed to evaluate an applicant" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    response = @sp_national_coordinator.send(:can_evaluate_applicant?, application)
    response.should be true
  end
  
  it "should be allowed to view the roster" do
    response = @sp_national_coordinator.send(:can_see_roster?)
    response.should be true
  end
  
  it "should be allowed to edit roles" do
    response = @sp_national_coordinator.send(:can_edit_roles?)
    response.should be true
  end
  
  it "should be allowed to upload ds" do
    response = @sp_national_coordinator.send(:can_upload_ds?)
    response.should be true
  end
  
  it "should be allowed to waive fee" do
    response = @sp_national_coordinator.send(:can_waive_fee?)
    response.should be true
  end
  
  it "should be allowed to view the dashboard" do
    response = @sp_national_coordinator.send(:can_see_dashboard?)
    response.should be true
  end
  
  it "should be allowed to view pd reports" do
    response = @sp_national_coordinator.send(:can_see_pd_reports?)
    response.should be true
  end
  
  it "should be allowed to view rc reports" do
    response = @sp_national_coordinator.send(:can_see_rc_reports?)
    response.should be true
  end
  
  it "should be allowed to view nc reports" do
    response = @sp_national_coordinator.send(:can_see_nc_reports?)
    response.should be true
  end
  
  it "should be allowed to search" do
    response = @sp_national_coordinator.send(:can_search?)
    response.should be true
  end
  
  
  it "should return an array ['1=1'] if the 'scope' when no partner specified" do
    response = @sp_national_coordinator.send(:scope)
    response.should == ['1=1']
  end
  
  it "should return an array if the 'scope' when a partner is specified" do
    partner = double(:person)
    response = @sp_national_coordinator.send(:scope, partner)
    response.should_not be nil
  end
  
  it "should return the default heading" do
    response = @sp_national_coordinator.send(:heading)
    response.should == "All open projects"
  end
  
  it "should return a string region when 'creatable_user_types' function is called" do
    @sp_national_coordinator.should_receive(:creatable_user_types_array).with("'SpRegionalCoordinator','SpNationalCoordinator','SpEvaluator','SpDirector','SpGeneralStaff'").and_return([])
    response = @sp_national_coordinator.send(:creatable_user_types)
    response.should == []
  end
  
  it "should return a string 'Director' when asking for its role" do
    response = @sp_national_coordinator.send(:role)
    response.should == 'National Coordinator'
  end
  
end