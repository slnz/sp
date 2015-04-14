require 'rack/contrib'
# Sp2::Application.config.middleware.use Rack::Locale
Sp2::Application.config.middleware.use Rack::TimeZone
