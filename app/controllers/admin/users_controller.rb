class Admin::UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  def index
    
  end
end
