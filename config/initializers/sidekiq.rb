require 'sidekiq'
require Rails.root.join('config', 'initializers', 'redis')

Sidekiq.configure_client do |config|
  config.redis = { url: $redis.client.id,
                   namespace: "SP:#{Rails.env}:resque"}
end

Sidekiq.configure_server do |config|
  config.redis = { url: $redis.client.id,
                   namespace: "SP:#{Rails.env}:resque"}
  config.failures_default_mode = :exhausted
end


