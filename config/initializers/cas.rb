  CASClient::Frameworks::Rails3::Filter.configure(
    :cas_base_url => "https://signin.relaysso.org/cas",
    :login_url => "https://signin.relaysso.org/cas/login",
    :validate_url => "https://signin.relaysso.org/cas/serviceValidate"
  )
  
# CAS::Filter.login_url = "https://signin.ccci.org/cas/login"
# CAS::Filter.validate_url = "https://signin.ccci.org/cas/serviceValidate"
