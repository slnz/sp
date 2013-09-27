class ChoiceField < Question
  include ChoiceFieldConcern

  def ptemplate
    if self.style == 'project-preference'
      'project_preference'
    else
      super
    end
	end

end
