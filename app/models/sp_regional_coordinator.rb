class SpRegionalCoordinator < SpUser
  def can_change_project_status?
    true
  end

  def can_change_self?
    true
  end

  def can_add_user?
    false
  end

  def can_add_applicant?
    true
  end

  def can_see_other_regions?
    true
  end

  def can_see_roster?
    true
  end

  def can_evaluate_applicant?(_app = nil)
    true
  end

  def can_edit_roles?
    true
  end

  def can_edit_project?(_project)
    true
  end

  def can_see_dashboard?
    true
  end

  def can_see_pd_reports?
    true
  end

  def can_see_rc_reports?
    true
  end

  def can_search?
    true
  end

  def scope(partner = nil)
    partner ||= region
    if ministry_mappings.key?(partner)
      partner = translations[partner]
    end
    @scope ||= ['primary_partner ilike :partner OR secondary_partner ilike :partner
                    OR tertiary_partner ilike :partner', partner: partner]
  end

  def heading(partner)
    partner = 'All' if partner == '%'
    "#{partner} Projects"
  end

  def creatable_user_types
    creatable_user_types_array("'SpRegionalCoordinator','SpEvaluator'")
  end

  def region
    @region ||= user.person.region
  end

  def role
    'Regional Coordinator'
  end
end
