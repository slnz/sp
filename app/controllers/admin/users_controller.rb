class Admin::UsersController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  respond_to :js, :html
  
  layout 'admin'
  
  def index
    params[:type] ||= 'national'
    @users =  case params[:type]
              when 'national'
                @role = 'National Coordinator'
                SpUser.where(:type => 'SpNationalCoordinator')
              when 'regional'
                @role = 'Regional Coordinator'
                SpUser.where(:type => 'SpRegionalCoordinator')
              when 'directors'
                @role = 'Director'
                SpUser.where(:type => 'SpDirector')
              end
    @users = @users.joins(:person).includes(:person).order('ministry_person.lastName, ministry_person.firstName')
    @addresses = {}
    Address.where(:addressType => 'current', :fk_PersonID => @users.collect(&:person_id)).map {|a| @addresses[a.fk_PersonID] = a}
    respond_with(@users) do |format|
      format.js {render :partial => 'users', :locals => {:users => @users}}
    end
  end
  
  def destroy
    @user = SpUser.find(params[:id])
    @user.destroy
    respond_with(@user)
  end
  
  def search
    super
  end
  
  def create
    unless %w{national regional}.include?(params[:type]) && params[:person_id].present?
      render :nothing => true and return 
    end
    base = case params[:type]
           when 'national'
             SpNationalCoordinator
           when 'regional'
             SpRegionalCoordinator
           end
    
    p = Person.find(params[:person_id])
    begin
      @user = base.create!(:person_id => p.id, :ssm_id => p.user.id, :created_by_id => current_person.id) if p && p.user
    rescue ActiveRecord::RecordNotUnique
    end
    respond_with(@user)
  end
end
