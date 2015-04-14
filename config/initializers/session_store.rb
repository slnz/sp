require File.join(Rails.root, 'app', 'middleware', 'flash_session_cookie_middleware')
require Rails.root.join('config', 'initializers', 'redis')

Sp2::Application.config.session_store :redis_session_store,
                                      key: '_sp2_session',
                                      redis: {
                                        db: 2,
                                        expire_after: 2.days,
                                        key_prefix: 'sp:session:',
                                        host: $redis.client.host, # Redis host name, default is localhost
                                        port: $redis.client.port   # Redis port, default is 6379
                                      }

Sp2::Application.configure do
  config.middleware.use('FlashSessionCookieMiddleware')
end
