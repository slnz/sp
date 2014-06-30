require 'spec_helper'

describe SpNationalCoordinator do
  before(:each) do
    @person = create(:person)
    @user = create(:user, person: @person)
    @sp_user = create(:sp_user, person: @person)
    @sp_national_coordinator = create(:sp_national_coordinator, person: @person, user: @user)
  end
  
  it "is allowed to delete a project" do
    response = @sp_national_coordinator.send(:can_delete_project?)
    expect(response).to be_truthy
  end
  
  it "is allowed to change a project status" do
    response = @sp_national_coordinator.send(:can_change_project_status?)
    expect(response).to be_truthy
  end
  
  it "is allowed to change its info" do
    response = @sp_national_coordinator.send(:can_change_self?)
    expect(response).to be_truthy
  end
  
  it "is allowed to add a user" do
    response = @sp_national_coordinator.send(:can_add_user?)
    expect(response).to be_truthy
  end
  
  it "is allowed to add an applicant" do
    response = @sp_national_coordinator.send(:can_add_applicant?)
    expect(response).to be_truthy
  end
  
  it "is allowed to view other regions" do
    response = @sp_national_coordinator.send(:can_see_other_regions?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit a project" do
    project = create(:sp_project)
    response = @sp_national_coordinator.send(:can_edit_project?, project)
    expect(response).to be_truthy
  end
  
  it "is allowed to merge a project" do
    response = @sp_national_coordinator.send(:can_merge_projects?)
    expect(response).to be_truthy
  end
  
  it "is allowed to su application" do
    response = @sp_national_coordinator.send(:can_su_application?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit references" do
    response = @sp_national_coordinator.send(:can_edit_references?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit a questionnaire" do
    response = @sp_national_coordinator.send(:can_edit_questionnaire?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit payments" do
    response = @sp_national_coordinator.send(:can_edit_payments?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit applicant's info" do
    response = @sp_national_coordinator.send(:can_edit_applicant_info?)
    expect(response).to be_truthy
  end
  
  it "is allowed to evaluate an applicant" do
    project = create(:sp_project)
    application = create(:sp_application, person: @person, project: project)
    response = @sp_national_coordinator.send(:can_evaluate_applicant?, application)
    expect(response).to be_truthy
  end
  
  it "is allowed to view the roster" do
    response = @sp_national_coordinator.send(:can_see_roster?)
    expect(response).to be_truthy
  end
  
  it "is allowed to edit roles" do
    response = @sp_national_coordinator.send(:can_edit_roles?)
    expect(response).to be_truthy
  end
  
  it "is allowed to upload ds" do
    response = @sp_national_coordinator.send(:can_upload_ds?)
    expect(response).to be_truthy
  end
  
  it "is allowed to waive fee" do
    response = @sp_national_coordinator.send(:can_waive_fee?)
    expect(response).to be_truthy
  end
  
  it "is allowed to view the dashboard" do
    response = @sp_national_coordinator.send(:can_see_dashboard?)
    expect(response).to be_truthy
  end
  
  it "is allowed to view pd reports" do
    response = @sp_national_coordinator.send(:can_see_pd_reports?)
    expect(response).to be_truthy
  end
  
  it "is allowed to view rc reports" do
    response = @sp_national_coordinator.send(:can_see_rc_reports?)
    expect(response).to be_truthy
  end
  
  it "is allowed to view nc reports" do
    response = @sp_national_coordinator.send(:can_see_nc_reports?)
    expect(response).to be_truthy
  end
  
  it "is allowed to search" do
    response = @sp_national_coordinator.send(:can_search?)
    expect(response).to be_truthy
  end
  
  
  it "returns an array ['1=1'] if the 'scope' when no partner specified" do
    response = @sp_national_coordinator.send(:scope)
    expect(response).to eq ['1=1']
  end
  
  it "returns an array if the 'scope' when a partner is specified" do
    partner = double(:person)
    response = @sp_national_coordinator.send(:scope, partner)
    expect(response).not_to be_nil
  end
  
  it "returns the default heading" do
    response = @sp_national_coordinator.send(:heading)
    expect(response).to eq "All open projects"
  end
  
  it "returns a string region when 'creatable_user_types' function is called" do
    expect(@sp_national_coordinator).to receive(:creatable_user_types_array).with("'SpRegionalCoordinator','SpNationalCoordinator','SpEvaluator','SpDirector','SpGeneralStaff'").and_return([])
    response = @sp_national_coordinator.send(:creatable_user_types)
    expect(response).to eq []
  end
  
  it "returns a string 'Director' when asking for its role" do
    response = @sp_national_coordinator.send(:role)
    expect(response).to eq 'National Coordinator'
  end
  
end