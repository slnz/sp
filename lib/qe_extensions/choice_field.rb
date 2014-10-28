Fe::ChoiceField.class_eval do

  def ptemplate
    if self.style == 'checkbox'
      'checkbox_field'
    elsif self.style == 'drop-down'
      'drop_down_field'
    elsif self.style == 'radio'
      'radio_button_field'
    elsif self.style == 'yes-no'
      'yes_no'
    elsif self.style == 'rating'
      'rating'
    elsif self.style == 'acceptance'
      'acceptance'
    elsif self.style == 'country'
      'country'
    elsif self.style == 'project-preference'
      'project_preference'
    end
  end

end
