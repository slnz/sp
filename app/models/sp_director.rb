class SpDirector < SpUser
  def can_add_applicant?() true; end
  def can_edit_applicant_info?() true; end
  def can_evaluate_applicant?() true; end
  def can_see_roster?() true; end
  def can_see_dashboard? 
    person.directed_projects.length > 1 
  end
  
  def scope(var = nil)
    @scope ||= ['pd_id = ? OR apd_id = ? OR opd_id = ? OR coordinator_id = ?' , person.id, person.id, person.id, person.id]
  end
  
  def heading(val = nil) "My Projects"; end;
end
