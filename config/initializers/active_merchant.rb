GATEWAY = ActiveMerchant::Billing::AuthorizeNetGateway.new(
 :login => '27KDcrXv4q',
 :password => '36k8RJ28QBn3a8mh'
) unless defined? GATEWAY
ActiveMerchant::Billing::AuthorizeNetGateway.live_url = "https://test.authorize.net/gateway/transact.dll"
