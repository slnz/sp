Fe::ChoiceField.class_eval do
  puts 'here1'
  def ptemplate
    puts 'here2'
    binding.pry
    case style
    when 'project-preference'
      'fe/project_preference'
    else
      super
    end
  end
end
