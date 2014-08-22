# SchoolPicker
# - a two-part question to search for the user's school
require 'infobase/target_area'
class SchoolPicker < Question
  def state(app=nil)
    if !app.nil?
      # try to get state from the applicant
      state = app.person.universityState
      unless state.present?
        # get from the campus
        name = response(app)
        campus = TargetArea.get(name: name)
        if campus.present?
          state = campus['state']
        end
      end
    end
    state.to_s
  end  
  
  def colleges(app=nil)
    unless state(app) == ''
      return Infobase::TargetArea.get(type: 'College', state: state(app))['target_areas'].collect { |t| t['name'] }
    end
    []
  end

  def high_schools(app=nil)
    unless self.state(app) == ''
      return Infobase::TargetArea.get(type: 'HighSchool')['target_areas'].collect { |t| t['name'] }
    end
    []
  end
  
  def validation_class
    if self.required?
      'validate-selection required'
    else
      ''
    end
  end
end