class Admin::ApplicationsController < ApplicationController
  before_filter :cas_filter, :authentication_filter
  before_filter :get_application, :only => [:waive_fee, :donations]
  before_filter :can_waive_fee, :only => [:waive_fee]
  before_filter :can_search, :only => [:search]

  respond_to :html, :js

  layout 'admin'

  def search
    set_up_search_form
  end

  def search_results
    set_up_search_form
    conditions = [[],[]]
    if params[:first_name] && !params[:first_name].empty?
      conditions[0] << "#{Person.table_name}.first_name like ?"
      conditions[1] << "%#{params[:first_name]}%"
    end
    if params[:last_name] && !params[:last_name].empty?
      conditions[0] << "#{Person.table_name}.last_name like ?"
      conditions[1] << "%#{params[:last_name]}%"
    end
    if params[:school] && !params[:school].empty?
      conditions[0] << "#{Person.table_name}.campus = ?"
      conditions[1] << params[:school]
    end
    if params[:team] && !params[:team].empty?
      # rather than join the team stuff into the main query it's going to be
      # cleaner to query out the campuses associated with this team seperately.
      # I know that means an extra query, but trust me, it's better.
      @schools = Infobase::TargetArea.get('filters[team_id]' => params[:team]).map(&:name)
      if @schools.empty?
        conditions[0] << " 1 <> 1 "
      else
        conditions[0] << "#{Person.table_name}.campus IN (?)"
        conditions[1] << @schools
      end
    end
    if params[:region] && !params[:region].empty?
      conditions[0] << "#{Person.table_name}.region = ?"
      conditions[1] << params[:region]
    end
    if params[:city] && !params[:city].empty?
      conditions[0] << "#{Address.table_name}.city = ?"
      conditions[1] << params[:city]
    end
    if params[:state] && !params[:state].empty?
      conditions[0] << "#{Address.table_name}.state = ?"
      conditions[1] << params[:state]
    end
    if params[:designation] && !params[:designation].empty?
      conditions[0] << "#{SpApplication.table_name}.designation_number = ?"
      conditions[1] << params[:designation]
    end
    if params[:project_type] && !params[:project_type].empty?
     conditions[0] << "#{SpProject.table_name}" + get_project_type_condition
    end
    if params[:status] && !params[:status].empty?
      conditions[0] << "#{SpApplication.table_name}.status = ?"
      conditions[1] << params[:status]
    end
    if params[:year] && !params[:year].empty?
      conditions[0] << "#{SpApplication.table_name}.year = ?"
      conditions[1] << params[:year]
    end
    if params[:preference] && !params[:preference].empty?
      conditions[0] << "project_id = ?"
      conditions[1] << params[:preference].to_i
    end
    conditions[0] = conditions[0].join(' AND ')
    conditions.flatten!(1)
    if conditions[0].empty?
      flash[:notice] = "You must use at least one search criteria."
      redirect_to search_admin_applications_path
    else
      search = SpApplication.where(conditions)
                            .includes([:project, {:person => :current_address}])
                            .order("#{SpApplication.table_name}.year desc, ministry_person.last_name, ministry_person.first_name")
                            .references([:project, {:person => :current_address}])
      if params[:page] == "all"
        @applications = search.paginate(:page => 1)
        @all_applications = search
      else
        @applications = search.paginate(:page => params[:page])
      end
    end
  end

  def other_donations
    @staff = SpStaff.find(params[:staff_id])
    @person = @staff.person
    @project = @staff.sp_project
    @designation = @person.sp_designation_numbers.where(project_id: @project.id, year: SpApplication.year).first
    unless @designation
      render text: "This person does not have a designation number yet."
    end
  end

  def donations
    @project = @application.project
  end

  def waive_fee
    @application.waive_fee!
    redirect_to :back
  end

  protected
    def set_up_search_form
      @region_options = Region.all
      @team_options = Infobase::Team.get('filters[lane]' => 'FS')
      @school_options = Infobase::TargetArea.get('filters[country]' => 'USA','per_page' => '30000').collect(&:name).uniq.sort
      @project_options = SpProject.current.order(:name)
    end

    def get_project_type_condition
      if params[:project_type] == 'US'
        return ".country = 'United States'"
      else
        return ".country <> 'United States'"
      end
    end

    def get_application
       @application = SpApplication.includes(:person).find(params[:id])
    end

    def can_waive_fee
      unless sp_user.nil? || sp_user.can_waive_fee?
        flash[:error] = 'You don\'t have permission to waive fees.'
        redirect_to :back and return false
      end
    end

    def can_search
      unless sp_user.nil? || sp_user.can_search?
        redirect_to no_admin_projects_path and return false
      end
    end
end
