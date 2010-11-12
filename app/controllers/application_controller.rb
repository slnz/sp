require 'authenticated_system'
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  before_filter :set_time_zone
  protect_from_forgery
  def self.application_name
    'SP'
  end
  
  def application_name
    ApplicationController.application_name
  end
  
  def set_time_zone
    Time.zone = request.env['rack.timezone.utc_offset'].present? ? request.env['rack.timezone.utc_offset'] : -14400
  end
    
  protected
    def dashboard_path
      if sp_user.can_see_dashboard? || current_person.current_staffed_projects.length > 1
        admin_projects_path
      elsif current_person.current_staffed_projects.length == 1
        admin_project_path(current_person.current_staffed_projects.first)
      else
        search_admin_applications_path
      end
    end
    
    def partners
      @partners ||= begin
        @partners = Region.where("region <> ''").collect(&:region)
        @partners += Ministry.all.collect(&:name)
      end
    end
    helper_method :partners

    def current_user
      unless @current_user
        if session[:user_id]
          @current_user = User.find_by_id(session[:user_id])
          # developer method to override user in session for testing
          if params[:user_id] && params[:su] && (@current_user.developer? || (session[:old_user_id] && old_user = User.find(session[:old_user_id]).developer?))
            session[:old_user_id] = @current_user.id if @current_user.developer?
            session[:user_id] = params[:user_id] 
            @current_user = User.find_by_id(session[:user_id])
          end
        end
        if session[:casfilterreceipt]
          @current_user ||= User.find_by_globallyUniqueID(session[:casfilterreceipt].attributes[:ssoGuid])
        end
      end
      @current_user
    end
    helper_method :current_user

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
      if @sp_user.nil? && current_person.isStaff?
        @sp_user = SpGeneralStaff.create(:ssm_id => current_user.id, :created_by_id => current_user.id, :person_id => current_person.id)
      end
      unless session[:login_stamped] || @sp_user.nil?
        @sp_user.update_attribute(:last_login, Time.now)
        session[:login_stamped] = true
      end
      @sp_user
    end
    helper_method :sp_user
    
    def check_valid_user
      if CASClient::Frameworks::Rails::Filter.filter(self) && AuthenticationFilter.filter(self)
        unless current_user.developer?
        # unless sp_user && sp_user.can_edit_questionnaire?
          redirect_to '/'
          return false
        end
      else
        return false
      end
    end
    
    def check_sp_user
      unless sp_user
        # Some people don't have sp users who should. Before blocking them, let's try creating one
        return true if @sp_user = SpUser.create_max_role(current_person.id) if current_person
        redirect_to :controller => :projects, :action => :no
        return false
      end
    end
    
    def leader_types
      %w{pd apd opd coordinator}
    end
    helper_method :leader_types
    
    def search
      if params[:name].present?
        term = '%' + params[:name].strip + '%'
        conditions = ["preferredName like ? OR firstName like ? OR lastName like ? OR concat(firstname, ' ', lastname) like ? OR concat(preferredName, ' ', lastname) like ?", term, term, term, params[:name].strip + '%', params[:name].strip + '%']
        @people = Person.where(conditions).includes(:user).limit(10)
        @total = Person.where(conditions).count
        respond_with(@people)
      else
        render :nothing => true
      end
    end
    
    
    def initialize_addresses
      # if @application.respond_to?(:person) && (@application.person.current_address.nil? || @application.person.current_address.nil? ||
      #                                           @application.person.emergency_address.nil?)
      #   @application.person.create_current_address if @application.person.current_address.nil?
      #   @application.person.create_permanent_address if @application.person.permanent_address.nil?
      #   @application.person.create_emergency_address if @application.person.emergency_address.nil?
      #   @application.person.reload
      # end
    end
end
