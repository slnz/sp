class SpGospelInAction < ActiveRecord::Base
  has_many :project_gospel_in_actions, :class_name => "SpProjectGospelInAction", :foreign_key => "sp_gospel_in_action_id"
  default_scope order(:name)
end
