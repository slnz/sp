if defined?(OmniAuth::Builder)
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, APP_CONFIG[:facebook_api_key], APP_CONFIG[:facebook_secret_key], {:scope => 'user_about_me,user_birthday,email,offline_access'}
    provider :CAS, :host => 'https://signin.ccci.org/cas', :name => 'relay'
  end
  OmniAuth.config.logger = Rails.logger
end

