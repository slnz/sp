class ApplicationController < ActionController::Base
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter AuthenticationFilter
  protect_from_forgery

  protected
    
    def partners
      @partners ||= begin
        @partners = Region.where("region <> ''").collect(&:region)
        @partners += Ministry.all.collect(&:name)
      end
    end
    helper_method :partners

    def current_user
      unless @current_user
        if session[:casfilterreceipt]
          @current_user ||= User.find_by_globallyUniqueID(session[:casfilterreceipt].attributes[:ssoGuid])
          return @current_user
        end
        if session[:user_id]
          @current_user ||= User.find_by_id(session[:user_id])
          return @current_user
        end
      end
      @current_user
    end
    helper_method :user

    def current_person
      unless @current_person
        raise "no user" unless current_user
        # Get their user, or create a new one if theirs doesn't exist
        @current_person = current_user.person || current_user.create_person_and_address
      end
      @current_person
    end
    helper_method :current_person

    # set up access control
    def sp_user
      return nil unless current_user
      @sp_user ||= SpUser.find_by_ssm_id(current_user.id)
      unless @sp_user
        # check to see if they are staff
        @sp_user = current_person.isStaff? ? SpUser.new(:ssm_id => current_user.id) : nil
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
