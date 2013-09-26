require 'global_registry'

GlobalRegistry.configure do |config|
  config.access_token = APP_CONFIG['global_registry_token']
  config.base_url = APP_CONFIG['global_registry_url']
end

