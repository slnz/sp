require 'csv'

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

    respond_to do |format|
      format.html
      format.csv { 
        @applications = SpApplication.where(:project_id => projects.collect(&:id), :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address})
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Project Name", "Status", "Name", "Gender", "Region", 
            "School", "1st Preference", "2nd Preference", "Email", "Phone" ]
          @applications.each do |app|
            csv << [ app.project.name, app.status.titleize, app.name, app.person.human_gender, app.person.region,
              app.person.campus, app.preference1 || app.project, app.preference2, app.email, app.person.phone ]
          end
        end
        render :text => csv
      }
    end
  end

  def evangelism
    #national: sees list of all partnerships
    # regional: list of all projects in my partnerships
    # director: list of all projects i'm directing, or straight to the 1

    if params[:project_id].present?
      @project = SpProject.find(params[:project_id])
    elsif sp_user.is_a?(SpNationalCoordinator)
      @projects = SpProject.current.order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator) && sp_user.partnerships.present?
      @projects = SpProject.with_partner(sp_user.partnerships).order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator) || sp_user.is_a?(SpDirector)
      if current_person.directed_projects.length > 1
        @projects = current_person.directed_projects.order("name ASC")
      else
        @project = current_person.directed_projects.first
      end
    end
  end

  def evangelism_combined
    if params[:partner].present?
      @partners = [ params[:partner] ]
      @statistic = Statistic.find_by_sql("select #{Statistic.column_names.collect{ |cn| "sum(ministry_statistic.#{cn}) as #{cn}" }.join(',')} from sp_projects " +
        "left join ministry_targetarea on sp_projects.id = ministry_targetarea.eventKeyID and eventType = 'SP' " +
        "left join ministry_activity on ministry_activity.fk_targetAreaID = ministry_targetarea.`targetAreaID` " +
        "left join ministry_statistic on ministry_statistic.`fk_Activity` = ministry_activity.`ActivityID` " +
        "where sp_projects.primary_partner IN (#{@partners.collect{ |p| "'#{p}'" }.join(',')})").first
    elsif sp_user.is_a?(SpNationalCoordinator)
      partner
    elsif sp_user.is_a?(SpRegionalCoordinator) && sp_user.partnerships.present?
      partner
      @partners = @partners & sp_user.partnerships
    end

  end

  def emergency_contact
    if sp_user.is_a?(SpNationalCoordinator)
      @projects = SpProject.current.order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator)
      @projects = sp_user.partnerships
    end

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "name", "PDs", "start date", "end date", 
            "contact 1 name", "contact 1 role", "contact 1 phone", "contact 1 email",
            "contact 2 name", "contact 2 role", "contact 2 phone", "contact 2 email", 
            "departure city", "destination city", "date of departure", "date of return",
            "in country contact" ]
          @projects.each do |project|
            csv << [ project.name, 
              [project.pd, project.apd, project.opd].compact.collect{ |pd| "#{pd.full_name} (#{pd.email}, #{pd.phone})" }.join(", "),
              project.start_date, project.end_date, 
              project.project_contact_name, project.project_contact_role, project.project_contact_phone, project.project_contact_email,
              project.project_contact2_name, project.project_contact2_role, project.project_contact2_phone, project.project_contact2_email,
              project.departure_city, project.destination_city, project.date_of_departure, project.date_of_return, project.in_country_contact ]
          end
        end
        render :text => csv
      }
    end
  end

  def ready_after_deadline
    if sp_user.is_a?(SpNationalCoordinator)
      @projects = SpProject.current.order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator) && sp_user.partnerships.present?
      partner
      @partners = @partners & sp_user.partnerships
      @projects = SpProject.current.with_partner(@partners).order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator) || sp_user.is_a?(SpDirector)
      @projects = current_person.directed_projects.order("name ASC")
    end

    project_ids = @projects.collect(&:id)
    # Apply by Dec. 10 and hear back by Jan. 28
    # Apply by Jan. 24 and hear back by Feb. 28
    # Apply by Feb. 24 and hear back by Mar. 28
    d1 = Date.parse("Dec 10, #{SpApplication::YEAR - 1}")
    @d1_projects = SpProject.where(:id => project_ids).where(["sp_applications.year = ? AND completed_at <= ?", SpApplication::YEAR, d1]).joins(:sp_applications).group(:project_id).select("name, count(*) as app_count").where("sp_applications.status" => "ready").group_by{ |p| p.name }
    d2 = Date.parse("Jan 24, #{SpApplication::YEAR}")
    @d2_projects = SpProject.where(:id => project_ids).where(["sp_applications.year = ? AND completed_at > ? AND completed_at <= ?", SpApplication::YEAR, d1, d2]).joins(:sp_applications).group(:project_id).select("name, count(*) as app_count").where("sp_applications.status" => "ready").group_by{ |p| p.name }
    d3 = Date.parse("Feb 24, #{SpApplication::YEAR}")
    @d3_projects = SpProject.where(:id => project_ids).where(["sp_applications.year = ? AND completed_at > ? AND completed_at <= ?", SpApplication::YEAR, d2, d3]).joins(:sp_applications).group(:project_id).select("name, count(*) as app_count").where("sp_applications.status" => "ready").group_by{ |p| p.name }

    @c1_cutoff = Date.parse("Jan 28, #{SpApplication::YEAR}")
    @c2_cutoff = Date.parse("Feb 28, #{SpApplication::YEAR}")
    @c3_cutoff = Date.parse("Mar 28, #{SpApplication::YEAR}")
  end

  def applications_by_status
    if sp_user.is_a?(SpNationalCoordinator)
      @projects = SpProject.current.order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator) && sp_user.partnerships.present?
      partner
      @partners = @partners & sp_user.partnerships
      @projects = SpProject.current.with_partner(@partners).order("name ASC")
    elsif sp_user.is_a?(SpRegionalCoordinator) || sp_user.is_a?(SpDirector)
      @projects = current_person.directed_projects.order("name ASC")
    end

    @years = SpApplication.select("distinct year").order("year DESC").collect(&:year).compact
    @year = params[:year] || @years.first

    @counts = []
    @counts << [ "Accepted as Participant", SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Accepted as Student Staff", SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Ready", SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Submitted", SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Unsubmitted", SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Started", SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (Accepted as Participant)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (Accepted as Student Staff)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (Ready)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (Submitted)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (Unsubmitted)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (Started)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Withdrawn (No status set)", SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)").count ]
    @counts << [ "Declined", SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)").count ]
  end

  def region
    if params[:region].present?
      @applications = SpApplication.where('ministry_person.region' => params[:region], :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address}).paginate(:page => params[:page], :per_page => 50)
    else
      @regions = Region.standard_regions.collect(&:region)
    end

    respond_to do |format|
      format.html
      format.csv { 
        @applications = SpApplication.where('ministry_person.region' => params[:region], :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address})
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Accepted To", "Status", "Name", "Gender", "School", "Missional Team",
                   "1st Preference", "2nd Preference", "Email", "Phone" ]
          @applications.each do |app|
            csv << [ (app.project.name if app.accepted?), app.status.titleize, app.name, app.person.human_gender,
              app.person.campus, app.person.target_area.try(:teams).try(:first), app.preference1 || app.project,
              app.preference2, app.email, app.person.phone ]
          end
        end
        render :text => csv
      }
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

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Accepted To", "Status", "Name", "Gender", "School", "1st Preference", "2nd Preference",
            "3rd Preference", "Email", "Phone" ]
          @applications.each do |app|
            csv << [ (app.project.name if app.accepted?), app.status.titleize, app.name, app.person.human_gender,
              app.person.campus, app.preference1 || app.project, app.preference2, app.preference3, 
              app.email, app.person.phone ]
          end
        end
        render :text => csv
      }
    end
  end

  def school
    if params[:school].present?
      @applications = SpApplication.where("#{Person.table_name}.campus" => params[:school], :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address})
    else
      @schools = SpApplication.connection.select_values("select distinct(#{Person.table_name}.campus) FROM sp_applications LEFT OUTER JOIN ministry_person ON ministry_person.personID = sp_applications.person_id WHERE (sp_applications.year = #{year}) order by campus").reject(&:blank?)
    end

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Accepted To", "Status", "Name", "Gender", "1st Preference", "2nd Preference", "3rd Preference",
            "Email", "Phone" ]
          @applications.each do |app|
            csv << [ (app.project.name if app.accepted?), app.status.titleize, app.name, app.person.human_gender,
              app.preference1 || app.project, app.preference2, app.preference3, app.email, app.person.phone ]
          end
        end
        render :text => csv
      }
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
