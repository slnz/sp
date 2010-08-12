  CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => "https://signin.ccci.org/cas/login",
    :login_url => "https://signin.ccci.org/cas/login",
    :validate_url => "https://signin.ccci.org/cas/serviceValidate"
  )
  
# CAS::Filter.login_url = "https://signin.ccci.org/cas/login"
# CAS::Filter.validate_url = "https://signin.ccci.org/cas/serviceValidate"