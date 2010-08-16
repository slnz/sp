class SpProjectGospelInAction < ActiveRecord::Base
  belongs_to :gospel_in_action, :class_name => "SpGospelInAction", :foreign_key => "gospel_in_action_id"
  belongs_to :project, :class_name => "SpProject", :foreign_key => "project_id"
end
