require_dependency 'authenticated_system'
require_dependency 'authentication_filter'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  force_ssl(if: :ssl_configured?, except: :lb)
  around_filter :do_with_current_user
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
  # For all responses in this controller, return the CORS access control headers.
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  # If this is a preflight OPTIONS request, then short-circuit the
  # request, return only the necessary headers and return an empty
  # text/plain.

  def cors_preflight_check
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000'
  end

  def dashboard_path
    if sp_user.can_see_dashboard? || current_person.current_staffed_projects.length > 1
      admin_projects_path
    elsif current_person.current_staffed_projects.length == 1
      admin_project_path(current_person.current_staffed_projects.first)
    elsif sp_user.can_search?
      search_admin_applications_path
    else
      no_admin_projects_path
    end
  end

  def partners
    @partners ||= begin
      @partners = Region.all.collect(&:region)
      @partners += Ministry.all.collect(&:name)
      @partners += ["US Campus", "Non-USCM SPs"]
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
      if session['cas_extra_attributes']
        @current_user ||= User.find_by_globallyUniqueID(session['cas_extra_attributes']['ssoGuid'])
      end
    end
    @current_user
  end
  helper_method :current_user

  def current_person
    unless @current_person
      raise "no user" unless current_user
      # Get their user, or create a new one if theirs doesn't exist
      @current_person = current_user.person
      if @current_person.nil? && session[:cas_extra_attributes]
        @current_person = current_user.create_person_and_address(firstName: session[:cas_extra_attributes]['firstName'],
                                                                 lastName: session[:cas_extra_attributes]['lastName'])
      end
    end
    @current_person
  end
  helper_method :current_person

  # set up access control
  def sp_user
    return SpUser.new unless current_user
    @sp_user ||= SpUser.find_by_ssm_id(current_user.id)
    if @sp_user.nil? && current_person.isStaff?
      @sp_user = SpGeneralStaff.create(:ssm_id => current_user.id, :created_by_id => current_user.id, :person_id => current_person.id)
    end
    unless session[:login_stamped] || @sp_user.nil?
      @sp_user.update_attribute(:last_login, Time.now)
      session[:login_stamped] = true
    end
    @sp_user ||= SpUser.new
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

      query = params[:name].strip.split(' ')
      first, last = query[0].to_s + '%', query[1].to_s + '%'
      if last == '%'
        conditions = ["preferredName like ? OR firstName like ? OR lastName like ?", first, first, first]
      else
        conditions = ["(preferredName like ? OR firstName like ?) AND lastName like ?", first, first, last]
      end

      @people = Person.where(conditions).includes(:user).order("isStaff desc").order("accountNo desc")
      @people = @people.limit(10) unless params[:show_all].to_s == 'true'

      # Put staff at the top of the list
      staff = []
      non_staff = []
      @people.each do |person|
        if person.staff.present?
          staff << person
        else
          non_staff << person
        end
      end
      @people = staff + non_staff
      @total = Person.where(conditions).count
      respond_to do |format|
        format.html { render layout: false }
        format.js
      end
    else
      render :nothing => true
    end
  end

  def ssl_configured?
    !Rails.env.development? && !Rails.env.test?
  end

  def do_with_current_user
    Thread.current[:user] = current_user
    begin
      yield
    ensure
      Thread.current[:user] = nil
    end
  end

  def cas_filter
    CASClient::Frameworks::Rails::Filter.filter(self) unless session[:cas_user]
  end

  def authentication_filter
    AuthenticationFilter.filter(self)
  end
end
