SiebelDonations.configure do |config|
  config.oauth_token = APP_CONFIG['designation_access_token']
  config.default_timeout = 60000
  config.base_url = APP_CONFIG['designation_base_url']
end
