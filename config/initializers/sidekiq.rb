require 'sidekiq'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'],
                   namespace: "SP:#{rails_env}:resque"}
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'],
                   namespace: "SP:#{rails_env}:resque"}
  config.failures_default_mode = :exhausted
end


