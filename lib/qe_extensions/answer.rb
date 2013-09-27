Answer.class_eval do
  has_attached_file :attachment, :storage => :s3,
                    :s3_credentials => Rails.root.join("config/amazon_s3.yml"),
                    :path => "sp/applications/:attachment/:id/:filename"
end