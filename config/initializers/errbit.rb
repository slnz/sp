Airbrake.configure do |config|
  config.api_key = '8726d2d77ac8fbc4c0dc7cd72de11184'
  config.host    = 'errors.studentlife.org.nz'
  config.port    = 80
  config.secure  = config.port == 443
end
