class SpEvaluator < SpRegionalCoordinator
  def can_change_project_status?() false; end
  def can_change_self?() false; end
  def can_add_user?() false; end
  def can_see_other_regions?() false; end
  def can_evaluate_applicant?() true; end
  def can_see_roster?() true; end
  
  def creatable_user_types
    creatable_user_types_array(nil)
  end
  
  def region
    @region ||= user.person.region
  end
end
