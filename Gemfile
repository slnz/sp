source 'http://rubygems.org'

gem 'rails', '~> 4.1.6'
gem 'puma'

gem 'pg'
gem 'sidekiq'

# Needed for the new asset pipeline
gem 'sass-rails', '~> 4.0.3'
gem 'coffee-rails' # , '~> 3.2.1'
gem 'uglifier' # , '~> 1.3.0'
gem 'execjs'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-validation-rails'
gem 'acts_as_versioned', git: 'https://github.com/technoweenie/acts_as_versioned.git'
gem 'airbrake', '~> 3.1.5'
gem 'aws-sdk'
gem 'carmen', '~> 0.2.12'
gem 'dalli', '~> 2.2.1'
gem 'redis-session-store'
gem 'dynamic_form', '~> 1.1.4'
gem 'excelsior', '~> 0.1.0'
gem 'google-geocode', '~> 1.2.1', require: 'google_geocode'
gem 'liquid', '~> 2.4.1'
gem 'newrelic_rpm', '>= 3.5.3.25'
gem 'omniauth', '~> 1.2.0'
gem 'omniauth-cas', '~> 1.1.0'
gem 'omniauth-facebook', '~> 2.0.0'
gem 'paperclip', '~> 4.2.0'
gem 'rack-contrib', '~> 1.1.0' # 100ms
gem 'rb-fsevent', '~> 0.9'
gem 'retryable-rb', '~> 1.1.0'
gem 'siebel_donations', '~> 1.0.4'
gem 'spreadsheet', '~> 0.7.4'
gem 'tinymce-rails', '~> 4.0.6'
gem 'whenever', '~> 0.7.3'
gem 'will_paginate', '~> 3.0.0'
gem 'relay_api_client', git: 'git://github.com/CruGlobal/relay_api_client.git'
gem 'cru_lib', git: 'https://github.com/CruGlobal/cru_lib'
gem 'image_science', '~> 1.2.5'
gem 'sidekiq-failures'
gem 'sidekiq-unique-jobs'
gem 'geocoder'
gem 'versionist'
gem 'active_model_serializers', '=0.9.0'
gem 'rubycas-client'
gem 'aasm'
gem 'auto_strip_attributes'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'infobase'
gem 'default_value_for'
gem 'activesupport-json_encoder'
gem 'rest-client'

gem 'bootstrap-sass'
gem 'font-awesome-rails'

gem 'fe', github: 'CruGlobal/qe', branch: 'fe'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'rspec', '~> 3.0'
  gem 'quiet_assets'
  gem 'awesome_print'
  gem 'mailcatcher'
  gem 'meta_request'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard-spork'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-puma'
  gem 'guard-rubocop'
  gem 'dotenv'
end

group :test do
  gem 'database_cleaner'
  gem 'webmock'
  gem 'mock_redis'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'simplecov', require: false
  gem 'xray-rails'
  gem 'thin'
end

group :production do
  gem 'rails_12factor'
end
