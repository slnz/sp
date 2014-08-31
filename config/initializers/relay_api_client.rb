RelayApiClient.configure do |config|
  config.wsdl = 'https://signin.ccci.org/sso/selfservice/webservice/5.0?wsdl'
  config.linker_username = ENV['linker_username']
  config.linker_password = ENV['linker_password']
end
