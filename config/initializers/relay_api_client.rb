RelayApiClient.configure do |config|
  config.wsdl = 'https://signin.cru.org/sso/selfservice/webservice/5.0?wsdl'
  config.linker_username = APP_CONFIG['linker_username']
  config.linker_password = APP_CONFIG['linker_password']
end
