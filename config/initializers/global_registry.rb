require 'global_registry'

GlobalRegistry.configure do |config|
  config.access_token = ENV['global_registry_token']
  config.base_url = ENV['global_registry_url']
end
