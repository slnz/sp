Fe::ChoiceField.class_eval do
  def ptemplate
    case style
    when 'project-preference'
      'fe/project_preference'
    else
      super
    end
  end
end
