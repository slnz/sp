class SpDirector < SpUser
  def can_search?() true; end
  def can_add_applicant?() true; end
  def can_edit_applicant_info?() true; end
  def can_evaluate_applicant?(app=nil)
    return false unless app
    app.project_id && person.current_staffed_projects.collect(&:id).include?(app.project_id)
  end
  def can_see_roster?() true; end
  def can_see_dashboard? 
    person.directed_projects.length > 1 
  end
  def can_see_pd_reports?() true; end
  
  def scope(var = nil)
    @scope ||= ['pd_id = ? OR apd_id = ? OR opd_id = ? OR coordinator_id = ?' , person.id, person.id, person.id, person.id]
  end
  
  def heading(val = nil) "My Projects"; end;
  
  def role
    'Director'
  end
end
