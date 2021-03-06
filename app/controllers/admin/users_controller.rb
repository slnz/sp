class Admin::UsersController < ApplicationController
  before_action :cas_filter, :authentication_filter, :check_access
  respond_to :html, :js

  layout 'admin'

  def index
    params[:type] ||= 'national'
    @users =  case params[:type]
              when 'national'
                @role = 'National Coordinator'
                SpUser.where(type: 'SpNationalCoordinator')
              when 'regional'
                @role = 'Regional Coordinator'
                SpUser.where(type: 'SpRegionalCoordinator')
              when 'donation_services'
                @role = 'Donation Services User'
                SpUser.where(type: 'SpDonationServices')
              when 'directors'
                @role = 'Director'
                SpUser.where(type: 'SpDirector')
              end
    @users = @users.joins(:person).includes(:person).order('ministry_person.last_name, ministry_person.first_name')
    @addresses = {}
    Address.where(address_type: 'current', id: @users.collect(&:person_id)).map { |a| @addresses[a.id] = a }
    respond_with(@users) do |format|
      if params[:type] != 'national'
        format.html { render partial: 'users', locals: { users: @users } }
      else
        format.html { render layout: 'admin' }
      end
    end
  end

  def destroy
    @user = SpUser.find(params[:id])
    @user.destroy
    respond_to do |wants|
      wants.html { redirect_to admin_users_path }
      wants.js
    end
  end

  def search
    super
  end

  def create
    unless %w(national regional donation_services).include?(params[:type]) && params[:person_id].present?
      render(nothing: true) && return
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
      SpUser.delete_all(person_id: p.id)
      @user = base.create!(person_id: p.id, ssm_id: p.user.id, created_by_id: current_person.id) if p && p.user
    rescue ActiveRecord::RecordNotUnique
    end
    respond_with(@user)
  end

  private

  def check_access
    unless sp_user.can_add_user?
      redirect_to('/admin') && return
    end
  end
end
