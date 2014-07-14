GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
 :login => APP_CONFIG['merchant_login'],
 :password => APP_CONFIG['merchant_password']
) unless defined? GATEWAY
ActiveMerchant::Billing::AuthorizeNetGateway.live_url = "https://test.authorize.net/gateway/transact.dll"
