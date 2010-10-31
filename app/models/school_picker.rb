# SchoolPicker
# - a two-part question to search for the user's school

class SchoolPicker < Question
  def state(app=nil)
    if !app.nil?
      # try to get state from the applicant
      s = app.person.universityState
      if s.blank?
        # get from the campus
        c = Campus.find_by_name(response(app))
        if !c.nil?
          s = c.state
        end
      end
    end
    s.to_s
  end  
  
  def colleges(app=nil)
    unless self.state(app) == ""
      return Campus.find_all_by_state_and_type(self.state(app), 'College', :order => :name).to_a.collect {|c| c.name} 
    end
    []
  end
  
  def high_schools(app=nil)
    unless self.state(app) == ""
      return Campus.find_all_by_type('HighSchool', :order => :name).to_a.collect {|c| c.name} 
    end
    []
  end
  
  def validation_class
    if self.required?
      'validate-selection'
    else
      ''
    end
  end
end