# SchoolPicker
# - a two-part question to search for the user's school

module Fe
  class SchoolPicker < Question
    def state(app=nil)
      if !app.nil?
        # try to get state from the applicant
        state = app.person.universityState
        unless state.present?
          # get from the campus
          name = response(app)
          campus = Campus.find_by_name(name)
          if campus.present?
            state = campus.state
          end
        end
      end
      state.to_s
    end  
    
    def colleges(app=nil)
      unless state(app) == ''
        return Campus.where("type = 'College' AND (isClosed is null or isClosed <> 'T') AND state = ?", state(app))
                     .order(:name).pluck(:name)
      end
      []
    end
    
    def high_schools(app=nil)
      unless self.state(app) == ''
        return Campus.where(type: 'HighSchool').order(:name).pluck(:name)
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
end
