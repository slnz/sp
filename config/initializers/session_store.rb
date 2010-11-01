require File.join(Rails.root, 'app', 'middleware', 'flash_session_cookie_middleware')
require 'action_dispatch/middleware/session/dalli_store'
Sp2::Application.config.session_store :dalli_store, :memcache_server => ['127.0.0.1'], :namespace => 'sessions', :key => '_sp2_session', :expire_after => 2.hours

Sp2::Application.config.middleware.insert_before(
  ActionDispatch::Session::DalliStore,
  FlashSessionCookieMiddleware,
  Rails.application.config.session_options[:key]
)
