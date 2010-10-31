require_dependency Rails.root.join('vendor','plugins','questionnaire_engine','app','models','answer').to_s
class Answer < ActiveRecord::Base
  has_attached_file :attachment, :storage => :s3,
                                  :s3_credentials => Rails.root.join("config/amazon_s3.yml"),
                                  :path => "sp/applications/:attachment/:id/:filename"
end