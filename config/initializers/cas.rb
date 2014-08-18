require 'casclient'
require 'casclient/frameworks/rails/filter'

CASClient::Frameworks::Rails::Filter.configure(
  :cas_base_url => "https://thekey.me/cas",
  :login_url => "https://thekey.me/cas/login",
  :validate_url => "https://thekey.me/cas/serviceValidate"
)

# CAS::Filter.login_url = "https://signin.ccci.org/cas/login"
# CAS::Filter.validate_url = "https://signin.ccci.org/cas/serviceValidate"
