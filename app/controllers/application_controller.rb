class ApplicationController < ActionController::Base
  protect_from_forgery
  def self.application_name
    'SP'
  end
  
  def application_name
    ApplicationController.application_name
  end
    
  protected
    def dashboard_path
      if sp_user.can_see_dashboard?
        admin_projects_path
      elsif current_person.staffed_projects.length == 1
        admin_project_path(current_person.staffed_projects.first)
      else
        no_admin_projects_path
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
        if session[:casfilterreceipt]
          @current_user ||= User.find_by_globallyUniqueID(session[:casfilterreceipt].attributes[:ssoGuid])
        end
        if session[:user_id]
          @current_user ||= User.find_by_id(session[:user_id])
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
      unless session[:login_stamped] || @sp_user.nil?
        @sp_user.update_attribute(:last_login, Time.now)
        session[:login_stamped] = true
      end
      @sp_user
    end
    helper_method :sp_user
    
    def check_valid_user
      if CASClient::Frameworks::Rails::Filter.filter(self) && AuthenticationFilter.filter(self)
        unless sp_user && sp_user.can_edit_questionnaire?
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
        term = '%' + params[:name] + '%'
        conditions = ["firstName like ? OR lastName like ? OR concat(firstname, ' ', lastname) like ?", term, term, params[:name] + '%']
        @people = Person.where(conditions).includes(:user).limit(10)
        @total = Person.where(conditions).count
        respond_with(@people)
      else
        render :nothing => true
      end
    end
end
