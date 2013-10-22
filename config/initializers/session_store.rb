require File.join(Rails.root, 'app', 'middleware', 'flash_session_cookie_middleware')
require 'action_dispatch/middleware/session/dalli_store'
Sp2::Application.config.session_store ActionDispatch::Session::CacheStore, :namespace => 'sessions', :key => '_sp2_session_1', :expire_after => 2.days

Sp2::Application.config.middleware.insert_before(
  ActionDispatch::Session::CacheStore,
  FlashSessionCookieMiddleware,
  Rails.application.config.session_options[:key]
)
