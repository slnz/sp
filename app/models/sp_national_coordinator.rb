class SpNationalCoordinator < SpUser
  def can_delete_project?() true; end
  def can_change_project_status?() true; end
  def can_change_self?() true; end
  def can_add_user?() true; end
  def can_add_applicant?() true; end
  def can_see_other_regions?() true; end
  def can_edit_project?(project) true; end
  def can_merge_projects?() true; end
  def can_su_application?() true; end
  def can_edit_references?() true; end
  def can_edit_questionnaire?() true; end
  def can_edit_payments?() true; end
  def can_edit_applicant_info?() true; end
  def can_evaluate_applicant?(app=nil) true; end
  def can_see_roster?() true; end
  def can_edit_roles?() true; end
  def can_upload_ds?() true; end
  def can_waive_fee?() true; end
  def can_see_dashboard?() true; end
  def can_see_pd_reports?() true; end
  def can_see_rc_reports?() true; end
  def can_see_nc_reports?() true; end
  
  def scope(partner = nil)
    if partner
      @scope ||= ['primary_partner like ? OR secondary_partner like ? OR tertiary_partner like ?' , partner, partner, partner]
    else
      @scope ||= ['1=1'] # all projects
    end
  end
  
  def heading(partner = nil) "All open projects"; end;
  
  def creatable_user_types
    creatable_user_types_array("'SpRegionalCoordinator','SpNationalCoordinator','SpEvaluator','SpDirector','SpGeneralStaff'")
  end
  
  def role
    'National Coordinator'
  end
end
