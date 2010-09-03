class Admin::UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  respond_to :js, :html
  
  layout 'admin'
  
  def index
    type = params[:type] || 'national'
    @users = case type
                when 'national'
                  SpUser.where(:type => 'SpNationalCoordinator')
                when 'regional'
                  SpUser.where(:type => 'SpRegionalCoordinator')
                when 'directors'
                  SpUser.where(:type => 'SpDirector')
                end
    @users = @users.joins(:person).includes(:person).order('ministry_person.lastName, ministry_person.firstName')
    respond_with(@users) do |format|
      format.js {render :partial => 'users', :locals => {:users => @users}}
    end
  end
end
