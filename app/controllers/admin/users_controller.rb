class Admin::UsersController < ApplicationController
  before_filter :cas_filter, :authentication_filter, :check_access
  respond_to :html, :js
  
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
              when 'donation_services'
                @role = 'Donation Services User'
                SpUser.where(:type => 'SpDonationServices')
              when 'directors'
                @role = 'Director'
                SpUser.where(:type => 'SpDirector')
              end
    @users = @users.joins(:person).includes(:person).order('ministry_person.lastName, ministry_person.firstName')
    @addresses = {}
    Address.where(:addressType => 'current', :fk_PersonID => @users.collect(&:person_id)).map {|a| @addresses[a.fk_PersonID] = a}
    respond_with(@users) do |format|
      if params[:type] != 'national'
        format.html {render :partial => 'users', :locals => {:users => @users}}
      else
        format.html {render layout: 'admin'}
      end
    end
  end
  
  def destroy
    @user = SpUser.find(params[:id])
    @user.destroy if @user.present?
    respond_to do |wants|
      wants.html { redirect_to admin_user_path(@user) }
      wants.js
    end
  end
  
  def search
    super
  end
  
  def create
    unless %w{national regional donation_services}.include?(params[:type]) && params[:person_id].present?
      render :nothing => true and return 
    end
    base = case params[:type]
           when 'national'
             SpNationalCoordinator
           when 'regional'
             SpRegionalCoordinator
           when 'donation_services'
             SpDonationServices
           end
    
    p = Person.find(params[:person_id])
    begin
      # Delete their other roles
      SpUser.delete_all(:person_id => p.id)
      @user = base.create!(:person_id => p.id, :ssm_id => p.user.id, :created_by_id => current_person.id) if p && p.user
    rescue ActiveRecord::RecordNotUnique
    end
    respond_with(@user)
  end
  
  def check_access
    unless sp_user.can_add_user?
      redirect_to '/admin' and return
    end
  end
end
