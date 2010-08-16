class SpStudentQuote < ActiveRecord::Base
  belongs_to :project, :class_name => "SpProject", :foreign_key => "project_id"
end
