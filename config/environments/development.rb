Sp2::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  # config.cache_classes = true
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  # config.action_controller.perform_caching = true

  config.reload_plugins = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # config.after_initialize do
  #   Bullet.enable = true
  #   Bullet.bullet_logger = true
  #   Bullet.rails_logger = true
  #   Bullet.console = true
  #   Bullet.disable_browser_cache = true
  # end
  # Do not compress assets
  config.assets.compress = false


# Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.default_url_options= { :host => 'localhost:3000' }

  # Just log mail, don't send
  # config.action_mailer.delivery_method = :test
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :host => "localhost", :port => 1025 }
end
