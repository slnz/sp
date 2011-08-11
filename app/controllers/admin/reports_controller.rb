class Admin::ReportsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter, :check_access
  layout 'admin'
  def show
    if sp_user.is_a?(SpDirector)
      redirect_to :action => :director and return
    end
  end

  def director
    
  end

  def preference
    @applications = {}
    if current_person.directed_projects.length == 0
      flash[:error] = "You aren't directing any projects"
      redirect_to :back and return
    elsif current_person.directed_projects.length > 1
      current_person.directed_projects.each do |project|
        @applications[project] =  get_applications(project)
      end
    else
      project = current_person.directed_projects.first
      @applications[project] =  get_applications(project)
    end
  end

  def male_openings
    @percentages = {'0-50' => [], '51-99' => [], '100' => []}
    SpProject.current.uses_application.order(:name).each do |project|
      case 
      when project.percent_full_men < 50
        @percentages['0-50'] << project
      when project.percent_full_men < 100
        @percentages['51-99'] << project
      else
        @percentages['100'] << project
      end
    end
  end

  def female_openings
    @percentages = {'0-50' => [], '51-99' => [], '100' => []}
    SpProject.current.uses_application.order(:name).each do |project|
      case 
      when project.percent_full_women < 50
        @percentages['0-50'] << project
      when project.percent_full_women < 100
        @percentages['51-99'] << project
      else
        @percentages['100'] << project
      end
    end
  end

  def ministry_focus
    @focuses = SpMinistryFocus.order(:name)
  end

  def partner
    if params[:partner].present?
      projects = SpProject.current.with_partner(params[:partner]).select("id, year")
      year = projects.maximum(:year)
      @applications = SpApplication.where(:project_id => projects.collect(&:id), :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address}).paginate(:page => params[:page], :per_page => 50)
    else
      @partners = SpProject.connection.select_values('select distinct primary_partner from sp_projects order by primary_partner').reject!(&:blank?)
    end
  end

  def evangelism
    if params[:partner].present?
      @projects = SpProject.current.with_partner(params[:partner])
    elsif params[:project_id].present?
      @project = SpProject.find(params[:project_id])
    elsif sp_user.is_a?(SpNationalCoordinator)
      partner
    end
  end

  def ready_after_deadline
    
  end

  def region
    if params[:region].present?
      @applications = SpApplication.where('ministry_person.region' => params[:region], :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address}).paginate(:page => params[:page], :per_page => 50)
    else
      @regions = Region.standard_regions.collect(&:region)
    end
  end

  def missional_team
    if params[:team].present?
      @schools = TargetArea.joins(:activities).where('ministry_activity.fk_teamID' => params[:team]).map(&:name)
      @applications = SpApplication.where("#{Person.table_name}.campus" => @schools, :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address})
      @team = Team.find(params[:team])
    else
      schools = SpApplication.connection.select_values("select distinct(#{Person.table_name}.campus) FROM sp_applications LEFT OUTER JOIN ministry_person ON ministry_person.personID = sp_applications.person_id WHERE (sp_applications.year = #{year})")
      @teams = Team.where("#{TargetArea.table_name}.name" => schools).includes(:target_areas).order("#{Team.table_name}.name")
    end
  end

  def school
    if params[:school].present?
      @applications = SpApplication.where("#{Person.table_name}.campus" => params[:school], :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address})
    else
      @schools = SpApplication.connection.select_values("select distinct(#{Person.table_name}.campus) FROM sp_applications LEFT OUTER JOIN ministry_person ON ministry_person.personID = sp_applications.person_id WHERE (sp_applications.year = #{year}) order by campus").reject(&:blank?)
    end
  end

  def applicants
    @applications = SpApplication.where(:year => year).where("ministry_person.lastName <> ''").order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address}).paginate(:page => params[:page], :per_page => 50)
  end

  def pd_emails
    base = SpStaff.order("#{Person.table_name}.lastName, #{Person.table_name}.lastName").includes(:person => :current_address).year(year)
    @pds = base.pd.collect(&:email).reject(&:blank?).uniq
    @apds = base.apd.collect(&:email).reject(&:blank?).uniq
    @opds = base.opd.collect(&:email).reject(&:blank?).uniq
    @all = @pds + @apds + @opds
  end

  def student_emails
    if params[:status].present?
      statuses = case params[:status]
                 when 'accepted' then SpApplication.accepted_statuses
                 when 'started' then SpApplication.uncompleted_statuses
                 when 'ready' then SpApplication.ready_statuses
                 when 'withdrawn' then 'withdrawn'
                 end
      @applications = SpApplication.where(:status => statuses, :year => year).where(Address.table_name + ".email <> ''").includes(:project, {:person => :current_address})
    else
      @statuses = %w{accepted ready started withdrawn}
    end
  end

  protected
    def get_applications(project)
     SpApplication.preferrenced_project(project.id).for_year(project.year).order('ministry_person.lastName, ministry_person.firstName').includes(:person => :current_address)
    end

    def check_access
      unless sp_user.can_see_reports?
        flash[:error] = "You don't have access to the reports section"
        redirect_to('/admin') and return false
      end
      if %w{regional partner region missional_team school}.include?(params[:action]) && !(sp_user.is_a?(SpRegionalCoordinator) || sp_user.is_a?(SpNationalCoordinator))
        flash[:error] = 'You don\'t have access to those reports'
        redirect_to(admin_reports_path) and return false
      end
      if %w{national applicants pd_emails student_emails}.include?(params[:action]) && !(sp_user.is_a?(SpNationalCoordinator))
        flash[:error] = 'You don\'t have access to those reports'
        redirect_to(admin_reports_path) and return false
      end
    end

    def year
      year = SpProject.maximum(:year)
    end
end
