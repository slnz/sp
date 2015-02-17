class CcpClient
  BASE_URL = 'https://ccpstaging.ccci.org/api/v1/rest'

  def initialize(username, password, authnet_username, authnet_pass, base_url = nil)
    @username = username
    @password = password
    @authnet_username = authnet_username
    @authnet_pass = authnet_pass
    @base_url = base_url || BASE_URL
  end

  # @param [Payment] Payment object containing all the values from the form post
  def capture(payment)
    body = params(payment).to_json
    response = RestClient::Request.execute(
      method: :post,
      url: @base_url + '/transactions/authorize.net',
      user: @username,
      password: @password,
      payload: body,
      headers: { content_type: :json, accept: :json }
    )

    JSON.parse(response.to_str).merge(success: true)
  rescue RestClient::Exception => e
    response = e.response
    JSON.parse(response.to_str).merge(success: false)
  end

  def params(payment)
    {
      encryptedCardNumber: payment.encrypted_card_number,
      encryptedCardSecurityCode: payment.encrypted_security_code,
      expirationDate: "#{payment.expiration_year}-#{payment.expiration_month}",
      amount: payment.amount,
      currencyCode: "USD",
      billing: {
        firstName: payment.first_name,
        lastName: payment.last_name,
        address: payment.address,
        city: payment.city,
        state: payment.state,
        zip: payment.zip
      },

      invoice: {
        description: "Cru Summer Mission application",
        number: payment.application.id
      },

      merchantEmail: "summer.missions@cru.org",

      gatewayAuthentication: {
        apiId: @authnet_username,
        transactionKey: @authnet_pass
      }
    }
  end
end