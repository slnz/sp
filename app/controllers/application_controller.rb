class ApplicationController < ActionController::Base
  before_filter CASClient::Frameworks::Rails::Filter
  protect_from_forgery

  protected
    def partners
      @partners ||= begin
        @partners = Region.where("region <> ''").collect(&:region)
        @partners += Ministry.all.collect(&:name)
      end
    end
    helper_method :partners

    def user
      if session[:casfilterreceipt]
        @user ||= User.find_by_globallyUniqueID(session[:casfilterreceipt].attributes[:ssoGuid])
        return @user
      end
      if session[:user_id]
        @user ||= User.find_by_id(session[:user_id])
        return @user
      end
      return false unless @user
    end
    helper_method :user

    # set up access control
    def sp_user
      return nil unless user
      @sp_user ||= SpUser.find_by_ssm_id(user.id)
      unless @sp_user
        # check to see if they are staff
        @sp_user = user.person.isStaff? ? SpUser.new(:ssm_id => user.id) : nil
      end
      unless session[:login_stamped] || @sp_user.nil?
        @sp_user.update_attribute(:last_login, Time.now)
        session[:login_stamped] = true
      end
      @sp_user
    end
    helper_method :sp_user
    
    def check_valid_user
      unless sp_user
        redirect_to :controller => :projects, :action => :no_access
        return false
      end
    end
end
