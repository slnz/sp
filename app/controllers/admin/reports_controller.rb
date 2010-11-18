class Admin::ReportsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  layout 'admin'
  def show
    
  end
end
