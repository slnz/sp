if defined?(OmniAuth::Builder)
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, ENV['facebook_api_key'], ENV['facebook_secret_key'], {:scope => 'user_about_me,user_birthday,email,offline_access'}
    provider :CAS, :host => 'https://thekey.me/cas', :name => 'relay'
  end
  OmniAuth.config.logger = Rails.logger
end

