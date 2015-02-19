if defined?(OmniAuth::Builder)
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, APP_CONFIG['facebook_api_key'], APP_CONFIG['facebook_secret_key'],
             :scope => 'user_about_me,user_birthday,email',
             :client_options => {
               :site => 'https://graph.facebook.com/v2.0',
               :authorize_url => "https://www.facebook.com/v2.0/dialog/oauth"
             }
    provider :cas, :host => 'https://signin.cru.org/cas', :name => 'relay'
  end
  OmniAuth.config.logger = Rails.logger
end

