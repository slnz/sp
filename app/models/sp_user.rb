class SpUser < ActiveRecord::Base
  belongs_to :user, :foreign_key => :ssm_id
  belongs_to :person
  # before_save :set_role
  after_destroy :create_max_role
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
    person.directed_projects.include?(project)
  end
  def can_merge_projects?() false; end
  def can_su_application?() false; end
  def can_edit_references?() false; end
  def can_edit_questionnaire?() false; end
  def can_edit_payments?() false; end
  def can_edit_applicant_info?() false; end
  def can_evaluate_applicant?(app=nil) false; end
  def can_see_roster?() false; end
  def can_upload_ds?() false; end
  def can_see_dashboard?() false; end
  def can_see_pd_reports?() false; end
  def can_see_rc_reports?() false; end
  def can_see_nc_reports?() false; end
  def can_see_reports?() 
    can_see_pd_reports? || can_see_rc_reports? || can_see_nc_reports?
  end
  
  def set_acl(attributes = nil)
    @acl = {:projects => [:no_access]}
  end
  
  def region
    @region ||= person.region
  end

  def partnerships
    partnerships = [ministry_lookup(region), ministry_lookup(person.ministry), ministry_lookup(person.strategy), ministry_exceptions(ssm_id)].compact
    partnerships.reject! {|p| p.blank?}
    partnerships
  end
  
  def acl(*url)
    controller, action = url
    @acl[controller].nil? ? false : @acl[:controller].include?(action)
  end
  
  def heading(partner = nil) ''; end;
  
  # def set_role
  #   sp_role = SpRole.find_by_user_class(self[:type])
  #   self[:role] = sp_role.role if sp_role
  # end
  
  def role
    ''
  end
  
  # Give this person a role based on their involvement
  def create_max_role
    SpUser.create_max_role(person_id)
  end
  
  def self.create_max_role(person_id)
    p = Person.find(person_id)
    if p && p.user
      staffing = SpStaff.where(:person_id => p.id)
      base =  case true
              when !staffing.detect {|s| SpStaff::DIRECTORSHIPS.include?(s.type)}.nil?
                SpDirector
              when !staffing.detect {|s| s.type == 'Evaluator'}.nil?
                SpEvaluator
              when staffing.length > 0
                SpProjectStaff
              when p.isStaff?
                SpUser
              else
                nil
              end
      base.create!(:person_id => p.id, :ssm_id => p.user.id) if base
    end
  end
  
  
  protected
    def ministry_lookup(ministry)
      mappings = {"KEY" => "Keynote", "MIL" => "Valor", "SV" => "Student Venture", "SVNO" => "Student Venture", 
                  "JF" => "Jesus Film", "JESUS Film Project" => 'Jesus Film', "EPI" => "Epic", 'BRD' => 'Bridges'}
      mappings[ministry] || ministry
    end
    
    def ministry_exceptions(user_id)
      exceptions = {45460 => 'MK2MK'}
      exceptions[user_id]
    end
end
