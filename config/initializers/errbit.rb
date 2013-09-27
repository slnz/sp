Airbrake.configure do |config|
  config.api_key     = '01d3074d4c069dbd48baec3c1ed8c7fe'
  config.host        = 'errors.uscm.org'
  config.port        = 443
  config.secure      = config.port == 443
end
