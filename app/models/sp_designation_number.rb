class SpDesignationNumber < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :project, :class_name => 'SpProject'
  
end
