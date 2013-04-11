GcxApi.config do |c|
  c.gcx_url = APP_CONFIG['gcx_url'] || 'https://www.gcx.org'
  c.cas_url = APP_CONFIG['cas_url'] || 'https://thekey.me'
  c.cas_username = APP_CONFIG['cas_username']
  c.cas_password = APP_CONFIG['cas_password']
end
