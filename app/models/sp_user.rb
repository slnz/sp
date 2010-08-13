class SpUser < ActiveRecord::Base
  belongs_to :user, :foreign_key => :ssm_id
  before_save :set_role
  after_initialize :set_acl
  
  def can_delete_project?() false; end
  def can_edit_roles?() false; end
  def can_change_project_status?() false; end
  def can_create_project?() can_change_project_status?; end
  def can_change_self?() false; end
  def can_add_user?() false; end
  def can_add_applicant?() false; end
  def can_see_other_regions?() false; end
  def can_waive_fee?() false; end
  def creatable_user_types() []; end
  def creatable_user_types_array(types = nil)
    types.nil? ? [] : SpRole.find(:all, :conditions => "user_class IN (#{types})", :order => 'role').map { |role| [role.role, role.user_class] }
  end
  def can_edit_project?(project) 
    person_id = user.person.id
    project = SpProject.find(:first, :conditions => ["pd_id = ? or apd_id = ? or opd_id = ? or coordinator_id = ?", person_id, person_id, person_id, person_id])
    return true if project
    return false
  end
  def can_merge_projects?() false; end
  def can_su_application?() false; end
  def can_edit_references?() false; end
  def can_edit_questionnaire?() false; end
  def can_edit_payments?() false; end
  def can_edit_applicant_info?() false; end
  def can_evaluate_applicant?() false; end
  def can_see_roster?() false; end
  def can_upload_ds?() false; end
  def can_see_dashboard?() false; end
  
  def set_acl(attributes = nil)
    @acl = {:projects => [:no_access]}
  end
  
  def region
    @region ||= person.region
  end
  def scope(var = nil)
    @scope ||= ['1=0'] # default to showing nothing
  end
  def person
    @person ||= user.person if user
  end
  
  def acl(*url)
    controller, action = url
    @acl[controller].nil? ? false : @acl[:controller].include?(action)
  end
  
  def heading(partner = nil) ''; end;
  
  def set_role
    sp_role = SpRole.find_by_user_class(self[:type])
    self[:role] = sp_role.role if sp_role
  end
end
