require 'csv'

class Admin::ReportsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter, :check_access
  @@total_applicant_actions = [ :total_num_applicants_by_partner_of_project,
    :total_num_applicants_by_region, :total_num_applicants_to_all_sps, :total_num_applicants_to_wsn_sps_by_area,
    :total_num_applicants_by_efm, :total_num_applicants_to_hs_sps, :total_num_applicants_to_other_ministry_sps ]
  @@total_participant_actions = [ :total_num_participants_by_partner_of_project,
    :total_num_participants_by_region, :total_num_participants_to_all_sps, :total_num_participants_to_wsn_sps_by_area,
    :total_num_participants_by_efm, :total_num_participants_to_hs_sps, :total_num_participants_to_other_ministry_sps ]
  before_filter :set_total_applicant_statuses, :only => @@total_applicant_actions
  before_filter :set_total_participants_statuses, :only => @@total_participant_actions
  before_filter :set_year, :only => @@total_applicant_actions + @@total_participant_actions + [:projects_summary]
  before_filter :set_years, :only => @@total_applicant_actions + @@total_participant_actions + [:projects_summary]

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

    respond_to do |format|
      format.html
      format.csv {
        csv = ""
        CSV.generate(csv) do |csv|
          gender = 'men'
          @percentages.each do |percentage, projects|
            csv << [ "#{percentage}% Full" ]
            csv << [ "Name", "Fullness", "APD Email", "Primary Partner", "Project Length", "Ministry Focus", "Project Type" ]
            projects.each do |project|
              csv << [ project.name, 
                percentage == '100' ? 100 : number_with_precision(project.send("percent_full_#{gender}"), :precision => 0),
                gender == 'men' ? project.pd.try(:email) : project.apd.try(:email),
                project.primary_partner,
                project.weeks.to_i,
                project.primary_ministry_focus,
                project.report_stats_to
              ]
            end
            csv << [ "" ]
          end
        end
        render :text => csv
      }
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

    respond_to do |format|
      format.html
      format.csv {
        csv = ""
        CSV.generate(csv) do |csv|
          gender = 'women'
          @percentages.each do |percentage, projects|
            csv << [ "#{percentage}% Full" ]
            csv << [ "Name", "Fullness", "APD Email", "Primary Partner", "Project Length", "Ministry Focus", "Project Type" ]
            projects.each do |project|
              csv << [ project.name, 
                percentage == '100' ? 100 : number_with_precision(project.send("percent_full_#{gender}"), :precision => 0),
                gender == 'men' ? project.pd.try(:email) : project.apd.try(:email),
                project.primary_partner,
                project.weeks.to_i,
                project.primary_ministry_focus,
                project.report_stats_to
              ]
            end
            csv << [ "" ]
          end
        end
        render :text => csv
      }
    end
  end

  def ministry_focus
    @focuses = SpMinistryFocus.order(:name)

    respond_to do |format|
      format.html
      format.csv {
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Project Name", "PD Email Address" ]
          @focus = SpMinistryFocus.find params[:focus_id]
          @focus.sp_projects.current.each do |project|
            csv << [ project.name, ([project.pd.try(:email), project.apd.try(:email)].compact.join(' or ')) ]
          end
        end
        render :text => csv
      }
    end
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
  
  def mpd_summary
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

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Student Name", "Designation #", "Date", "Amount", "Donor Name", "Medium" ]
          @project.sp_applications.joins(:person).includes(:person).order('lastName, firstName').accepted_participants.for_year(year).each do |application|
              person = application.person
              application.donations.for_year(application.year).each do |donation|
                csv << [ person, application.designation_number, l(donation.donation_date),
                  number_to_currency(donation.amount), donation.donor_name, donation.medium ]
              end
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

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Year", "Media Exposures", "Evangelistic One-One", "Evangelistic Group", "Decisions", 
            "Decisions Media", "Decisions One-One", "Decisions Group", "Holy Spirit Convo",
            "Involved New Blvrs", "Involved Students", "Students Leaders", "Dollars Raised" ]
          @project.statistics.each do |stat|
            csv << [ 
              stat.stat_year,
              number_with_delimiter(stat.exposuresViaMedia.to_i),
              number_with_delimiter(stat.evangelisticOneOnOne.to_i),
              number_with_delimiter(stat.evangelisticGroup.to_i),
              number_with_delimiter(stat.decisions.to_i),
              number_with_delimiter(stat.decisionsHelpedByMedia.to_i),
              number_with_delimiter(stat.decisionsHelpedByOneOnOne.to_i),
              number_with_delimiter(stat.decisionsHelpedByGroup.to_i),
              number_with_delimiter(stat.decisionsHelpedByOngoingReln.to_i),
              number_with_delimiter(stat.holySpiritConversations.to_i),
              number_with_delimiter(stat.invldNewBlvrs.to_i),
              number_with_delimiter(stat.invldStudents.to_i),
              number_to_currency(stat.dollars_raised.to_i, precision: 0)
            ]
          end
        end
        render :text => csv
      }
    end
  end

  def evangelism_combined
    if params[:partner].present?
      @partners = [ params[:partner] ]
      columns_we_care_about = %w[exposuresViaMedia evangelisticOneOnOne evangelisticGroup decisions decisionsHelpedByMedia decisionsHelpedByOneOnOne 
                                 decisionsHelpedByGroup decisionsHelpedByOngoingReln holySpiritConversations invldNewBlvrs invldStudents
                                 dollars_raised]
      @statistics = Statistic.find_by_sql("select YEAR(ministry_statistic.periodBegin) as `stat_year`, #{columns_we_care_about.collect{ |cn| "sum(ministry_statistic.#{cn}) as #{cn}" }.join(',')} from sp_projects " +
        "left join ministry_targetarea on sp_projects.id = ministry_targetarea.eventKeyID and eventType = 'SP' " +
        "left join ministry_activity on ministry_activity.fk_targetAreaID = ministry_targetarea.`targetAreaID` " +
        "left join ministry_statistic on ministry_statistic.`fk_Activity` = ministry_activity.`ActivityID` " +
        "where sp_projects.primary_partner IN (#{@partners.collect{ |p| "'#{p}'" }.join(',')}) group by YEAR(periodBegin) order by stat_year desc")
      @statistics.select! {|s| s.stat_year.present?}
    elsif sp_user.is_a?(SpNationalCoordinator)
      partner
    elsif sp_user.is_a?(SpRegionalCoordinator) && sp_user.partnerships.present?
      partner
      @partners = @partners & sp_user.partnerships
    end

    if @statistics.present?
      respond_to do |format|
        format.html
        format.csv { 
          csv = ""
          CSV.generate(csv) do |csv|
            csv << [ "Year", "Media Exposures", "Evangelistic One-One", "Evangelistic Group", "Decisions", 
              "Decisions Media", "Decisions One-One", "Decisions Group", "Holy Spirit Convo",
              "Involved New Blvrs", "Involved Students", "Students Leaders", "Dollars Raised" ]
            @statistics.each do |stat|
              csv << [ 
                stat.stat_year,
                number_with_delimiter(stat.exposuresViaMedia.to_i),
                number_with_delimiter(stat.evangelisticOneOnOne.to_i),
                number_with_delimiter(stat.evangelisticGroup.to_i),
                number_with_delimiter(stat.decisions.to_i),
                number_with_delimiter(stat.decisionsHelpedByMedia.to_i),
                number_with_delimiter(stat.decisionsHelpedByOneOnOne.to_i),
                number_with_delimiter(stat.decisionsHelpedByGroup.to_i),
                number_with_delimiter(stat.decisionsHelpedByOngoingReln.to_i),
                number_with_delimiter(stat.holySpiritConversations.to_i),
                number_with_delimiter(stat.invldNewBlvrs.to_i),
                number_with_delimiter(stat.invldStudents.to_i),
                number_to_currency(stat.dollars_raised.to_i, precision: 0)
              ]
            end
          end
          render :text => csv
        }
      end
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

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Project", "PD email", "Applied by Dec 10", "Applied by Jan 24", "Applied by Feb 24" ]
          for project in @projects
            csv << [ project.name, project.try(:pd).try(:email),
              (Date.today >= @c1_cutoff) ? @d1_projects[project.name].try(:first).try(:app_count) : " ",
              (Date.today >= @c2_cutoff) ? @d2_projects[project.name].try(:first).try(:app_count) : " ",
              (Date.today >= @c3_cutoff) ? @d3_projects[project.name].try(:first).try(:app_count) : " "
            ]
          end
        end
        render :text => csv
      }
    end
 
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
    @counts << [ "Accepted as Participant", SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant'").count ]
    @counts << [ "Accepted as Student Staff", SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff'").count ]
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

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Status", "Count" ]
          for label, number in @counts
            csv << [ label, number ]
          end
        end
        render :text => csv
      }
    end
   end

  def region
    if params[:region].present?
      @applications = SpApplication.where('ministry_person.region' => params[:region], :year => year).order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address}).paginate(:page => params[:page], :per_page => 50)
    else
      @regions = Region.standard_region_codes
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
    respond_to do |format|
      format.html {
        @applications = SpApplication.where(:year => year).where("ministry_person.lastName <> ''").order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address}).paginate(:page => params[:page], :per_page => 50)
      }
      format.csv { 
        @applications = SpApplication.where(:year => year).where("ministry_person.lastName <> ''").order('ministry_person.lastName, ministry_person.firstName').includes(:project, {:person => :current_address})
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Accepted To", "Status", "Name", "Gender", "Region", "Missional Team", "School", "1st Preference",
            "Email", "Phone" ]
          @applications.each do |app|
            csv << [ (app.project.name if app.accepted?),
              app.status.titleize, app.name, app.person.human_gender, 
              app.person.region, app.person.target_area.try(:teams).try(:first),
              app.person.campus, app.preference1 || app.project,
              app.email, app.person.phone ]
          end
        end
        render :text => csv
      }
    end
  end

  def pd_emails
    base = SpStaff.order("#{Person.table_name}.lastName, #{Person.table_name}.lastName").includes(:person => :current_address).year(year)
    @pds = base.pd.collect(&:email).reject(&:blank?).uniq.sort
    @apds = base.apd.collect(&:email).reject(&:blank?).uniq.sort
    @opds = base.opd.collect(&:email).reject(&:blank?).uniq.sort
    @all = (@pds + @apds + @opds).uniq.sort

    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "email (#{params[:pd_type]})" ]
          @emails = case params[:pd_type]
          when 'pd_male'
            @pds
          when 'pd_female'
            @apds
          when 'opd'
            @opds
          when 'all'
            @all
          end
          @emails.each do |email|
            csv << [ email ]
          end
        end
        render :text => csv
      }
    end
  end

  def fee_by_staff
    respond_to do |format|
      format.html {
        @payments = SpPayment.joins(:application).where("sp_payments.status = 'Approved'").where("sp_applications.year = #{SpApplication::YEAR}").where("sp_payments.payment_type = 'Staff'").order("sp_payments.payment_account_no ASC").paginate(:page => params[:page], :per_page => 50)
      }
      format.csv { 
        @payments = SpPayment.joins(:application).where("sp_payments.status = 'Approved'").where("sp_applications.year = #{SpApplication::YEAR}").where("sp_payments.payment_type = 'Staff'").order("sp_payments.payment_account_no ASC")
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Project Name", "Project Start", "Project End", "PD Email", "APD EMail", "OPD EMail" ]
          @payments.each do |payment|
            csv << [ payment.payment_account_no,
              payment.amount, payment.application.person.firstName, payment.application.person.lastName,
              payment.status, payment.created_at
            ]
          end
        end
        render :text => csv
      }
    end
  end

  def project_start_end
    @projects = SpProject.current
    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << [ "Project Name", "Project Start", "Project End", "PD Email", "APD EMail", "OPD EMail" ]
          @projects.each do |project|
            csv << [ project.name, project.start_date, project.end_date,
              project.pd.try(:email), project.apd.try(:email), project.opd.try(:email)
            ]
          end
        end
        render :text => csv
      }
    end
  end
  
  def stats_by_project
    set_years
    set_year    
    @headers = [ "Project", "# Weeks", "# Student Participants", "Primary Partner", "Project Type", "PD Email", 
                "Media Exposures", 'Evangelistic One-One', 'Evangelistic Group', 'Decisions Media', 'Decisions One-One', 
                'Decisions Group', 'Holy Spirit Convo', 'Involved New Blvrs', 'Involved Students', 'Student Leaders', 'Dollars Raised' ]
    @rows = []
    SpProject.current.order('name').each do |project| 
      if stat = project.statistics.detect {|s| s.stat_year.to_i == @year.to_i}
        @rows << [project.name, project.weeks, project.sp_applications.for_year(@year).accepted.count, project.primary_partner, 
                  case project.report_stats_to when 'Campus Ministry - WSN summer project' then 'WSN'; when 'Campus Ministry - US summer project' then 'US'; else 'Other'; end, 
                  project.contact.try(:email), number_with_delimiter(stat.exposuresViaMedia.to_i), number_with_delimiter(stat.evangelisticOneOnOne.to_i), 
                  number_with_delimiter(stat.evangelisticGroup.to_i), 
                  number_with_delimiter(stat.decisionsHelpedByMedia.to_i), number_with_delimiter(stat.decisionsHelpedByOneOnOne.to_i), 
                  number_with_delimiter(stat.decisionsHelpedByGroup.to_i), number_with_delimiter(stat.decisionsHelpedByOngoingReln.to_i), 
                  number_with_delimiter(stat.holySpiritConversations.to_i), number_with_delimiter(stat.invldNewBlvrs.to_i), 
                  number_with_delimiter(stat.invldStudents.to_i), number_to_currency(stat.dollars_raised.to_i, precision: 0)]
      end
    end
    respond_to do |format|
      format.html
      format.csv { 
        csv = ""
        CSV.generate(csv) do |csv|
          csv << @headers
          @rows.each do |row|
            csv << row
          end
        end
        render :text => csv
      }
    end
  end

  def student_emails
    if params[:status].present?
      statuses = case params[:status]
                 when 'accepted' then SpApplication.accepted_statuses
                 when 'started' then SpApplication.uncompleted_statuses
                 when 'ready' then SpApplication.ready_statuses
                 when 'withdrawn' then 'withdrawn'
                 end
      @emails = SpApplication.where(:status => statuses, :year => year).where(Address.table_name + ".email <> ''").where("isStaff <> 1 OR isStaff Is Null").includes(:person => :current_address).select('email').collect(&:email).uniq.compact
    else
      @statuses = %w{accepted ready started withdrawn}
    end

    if @emails.present?
      respond_to do |format|
        format.html {
          @payments = SpPayment.joins(:application).where("sp_payments.status = 'Approved'").where("sp_applications.year = #{SpApplication::YEAR}").where("sp_payments.payment_type = 'Staff'").order("sp_payments.payment_account_no ASC").paginate(:page => params[:page], :per_page => 50)
        }
        format.csv { 
          @payments = SpPayment.joins(:application).where("sp_payments.status = 'Approved'").where("sp_applications.year = #{SpApplication::YEAR}").where("sp_payments.payment_type = 'Staff'").order("sp_payments.payment_account_no ASC")
          csv = ""
          CSV.generate(csv) do |csv|
            csv << [ "Project Name", "Project Start", "Project End", "PD Email", "APD EMail", "OPD EMail" ]
            @payments.each do |payment|
              csv << [ payment.payment_account_no,
                payment.amount, payment.application.person.firstName, payment.application.person.lastName,
                payment.status, payment.created_at
              ]
            end
          end
          render :text => csv
        }
      end
    end
  end
  
  def sending_stats
    @totals = {}
    @other_totals = {}
    @years = SpProject.connection.select_values("select distinct(year) from sp_projects order by year desc")
    Region.standard_regions.each do |region|
      @totals[region.region] = {}
      @years.each do |year|
        scope = SpApplication.accepted.joins(:project).where('sp_applications.year' => year).where('sp_projects.primary_partner' => region.region)
        @totals[region.region][year] = {'WSN' => scope.where("country <> 'United States' AND country <> ''").count,
                                        'USSP' => scope.where("country = 'United States'").count}
      end
    end
    @years.each do |year|
      @other_totals[year] = SpApplication.accepted.joins(:project).where('sp_applications.year' => year).where("sp_projects.primary_partner NOT IN(?)", Region.standard_region_codes).count
    end

    respond_to do |format|
      format.html
      format.csv { 
        columns = 5
        @total_wsn = {}
        @total_ussp = {}
        csv = ""
        CSV.generate(csv) do |csv|
          1.upto((@years.length.to_f / columns).ceil) do |i|
            row = []
            ((i-1) * columns).upto((i * columns) - 1).each do |j|
              next unless @years[j]
              row += [ @years[j], "WSN", "USSP", "Other", "TOTAL" ]
            end
            csv << row
            @totals.each do |region, years|
              row = []
              ((i-1) * columns).upto((i * columns) - 1).each do |j|
                year = @years[j]
                next unless year
                stats = years[year]
                @total_wsn[year] ||= 0
                @total_wsn[year] += stats['WSN']
                @total_ussp[year] ||= 0
                @total_ussp[year] += stats['USSP']
                row += [ region, stats['WSN'], stats['USSP'], '', stats['WSN'] + stats['USSP'] ]
              end
              csv << row
            end
            row = []
            ((i-1) * columns).upto((i * columns) - 1).each do |j|
              year = @years[j]
              next unless year
              row += [ "TOTAL", @total_wsn[year], @total_ussp[year], @other_totals[year], @total_wsn[year] + @total_ussp[year] + @other_totals[year] ]
            end
            csv << row
            csv << []
          end
        end
        render :text => csv
      }
    end
  end

  
  def total_num_participants_by_partner_of_project
    @statuses = [ "All Participants" ]
    @headers = SpProject.connection.select_values('select distinct primary_partner from sp_projects order by primary_partner ASC').reject!(&:blank?)

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        #@extra_query_parts = " AND project_status = 'open'"
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i]["All Participants"] = SpApplication.joins(:person).where(:year => @year).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff') AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end
  
  def total_num_applicants_by_partner_of_project
    @headers = SpProject.connection.select_values('select distinct primary_partner from sp_projects order by primary_partner ASC').reject!(&:blank?)

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        #@extra_query_parts = " AND project_status = 'open'"
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i][ "Accepted as Participant"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Accepted as Student Staff"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Ready"] = SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Submitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Unsubmitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Started"] = SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Accepted as Participant)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Accepted as Student Staff)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Ready)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Submitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Unsubmitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Started)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (No status set)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Declined"] = SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end


  def total_num_participants_by_region
    @headers = Region.standard_regions.collect(&:region)

    @counts = {}
    (0..2).each do |i|
      @extra_query_parts = ""
      if i == 0
        # male
        @extra_query_parts += " AND (gender IN (1, '1'))"
      elsif i == 1
        # female
        @extra_query_parts += " AND (gender IN (0, '0'))"
      end
      @counts ||= {}
      @counts[i] ||= {}
      @counts[i]["All Participants"] = SpApplication.joins(:person).where(:year => @year).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff') AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end
  
  def total_num_applicants_by_region
    @headers = Region.standard_regions.collect(&:region)

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i][ "Accepted as Participant"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Accepted as Student Staff"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Ready"] = SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Submitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Unsubmitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Started"] = SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (Accepted as Participant)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (Accepted as Student Staff)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (Ready)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (Submitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (Unsubmitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (Started)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Withdrawn (No status set)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i][ "Declined"] = SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_applicants_to_all_sps
    @headers = ["US", "WSN", "Other Ministries"]

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        for status in @statuses
          @counts[i][status] ||= {}
        end

        @extra_query_parts += " AND sp_projects.country = 'United States'"
        @counts[i]["Accepted as Participant"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Accepted as Student Staff"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Ready"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Submitted"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Unsubmitted"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Started"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Accepted as Participant)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Accepted as Student Staff)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Ready)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Submitted)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Unsubmitted)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Started)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (No status set)"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Declined"]["US"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count

        # I'm still not sure how to get WSN
        #    WSN means it's international, country <> 'United States'
        #    US, WSN would be anything from the 10 regions, then Other Ministries would be any other partner that isn't one of the 10 regions regardless of the country
        # But I don't see how to relate projects to regions...
        @extra_query_parts = " AND sp_projects.country <> 'United States'"
        @counts[i]["Accepted as Participant"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Accepted as Student Staff"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Ready"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Submitted"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Unsubmitted"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Started"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Accepted as Participant)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Accepted as Student Staff)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Ready)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Submitted)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Unsubmitted)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Started)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (No status set)"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Declined"]["WSN"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count

        @extra_query_parts = ""
        @counts[i]["Accepted as Participant"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Accepted as Student Staff"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Ready"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Submitted"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Unsubmitted"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Started"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Accepted as Participant)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Accepted as Student Staff)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Ready)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Submitted)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Unsubmitted)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (Started)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Withdrawn (No status set)"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
        @counts[i]["Declined"]["Other Ministries"] = SpApplication.joins(:person).where(:year => @year).joins(:project).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_applicants_to_wsn_sps_by_area
    @headers = [ "East Asia Opportunities", "East Asia Orient", "Eastern Europe/Russia", "Francophone Africa", "Latin America", "NAME", "Nigeria & West Africa",
      "North America and Oceania", "PACT", "South Asia", "SouthEast Asia", "Southern & Eastern Africa", "Western Europe" ]

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i]["Accepted as Participant"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Accepted as Student Staff"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Ready"] = SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Submitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Unsubmitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Started"] = SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (Accepted as Participant)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (Accepted as Student Staff)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (Ready)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (Submitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (Unsubmitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (Started)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Withdrawn (No status set)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
        @counts[i]["Declined"] = SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("region").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end


  def total_num_participants_by_efm
    @headers = [ "Bridges", 'Destino', 'Epic','Impact','Nations' ]

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i]["All Participants"] = SpApplication.joins(:project, :person).where(:year => @year).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff')#{@extra_query_parts}").group("primary_partner").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end
  
  def total_num_applicants_by_efm
    @headers = [ "Bridges", 'Destino', 'Epic','Impact','Nations' ]

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i]["Accepted as Participant"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Accepted as Student Staff"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Ready"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Submitted"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Unsubmitted"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Started"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (Accepted as Participant)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (Accepted as Student Staff)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (Ready)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (Submitted)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (Unsubmitted)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (Started)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Withdrawn (No status set)"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
        @counts[i]["Declined"] = SpApplication.joins(:project, :person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").group("primary_partner").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_applicants_to_hs_sps
    @headers = [ "Student Venture", "MK2MK" ]

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = " AND sp_projects.name NOT LIKE '%spring%'"
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i][ "Accepted as Participant"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Accepted as Student Staff"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Ready"] = SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Submitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Unsubmitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Started"] = SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Accepted as Participant)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Accepted as Student Staff)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Ready)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Submitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Unsubmitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Started)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (No status set)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Declined"] = SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_applicants_to_other_ministry_sps
    @headers = SpProject.connection.select_values("Select distinct(primary_partner) from sp_projects where report_stats_to = 'Other CCC ministry'").reject(&:blank?) - Region.standard_region_codes

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i][ "Accepted as Participant"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Accepted as Student Staff"] = SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Ready"] = SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Submitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Unsubmitted"] = SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Started"] = SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Accepted as Participant)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Accepted as Student Staff)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Ready)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Submitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Unsubmitted)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (Started)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Withdrawn (No status set)"] = SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count
        @counts[i][ "Declined"] = SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("primary_partner").count

        @counts[i][ "Accepted as Participant"].merge!(SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Accepted as Student Staff"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Ready"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Submitted"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Unsubmitted"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Started"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (Accepted as Participant)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_participant' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (Accepted as Student Staff)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'accepted_as_student_staff' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (Ready)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'ready' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (Submitted)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'submitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (Unsubmitted)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'unsubmitted' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (Started)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND previous_status = 'started' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Withdrawn (No status set)"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'withdrawn' AND (previous_status = '' OR previous_status IS NULL) AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
        @counts[i][ "Declined"].merge(SpApplication.joins(:person).where(:year => @year).where("status = 'declined' AND (isStaff <> 1 OR isStaff Is NULL)#{@extra_query_parts}").joins(:project).group("report_stats_to").count)
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_participants_to_all_sps
    @headers = ["US", "WSN", "Other Ministries"]

    @counts = {}
    scope = SpApplication.joins(:person).where(:year => @year).joins(:project).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff')")
    (0..2).each do |i|
      this_scope = scope
      if i == 0
        # male
        this_scope = scope.where("(gender IN (1, '1'))")
      elsif i == 1
        # female
        this_scope = scope.where("(gender IN (0, '0'))")
      end
      @counts ||= {}
      @counts[i] ||= {}
      for status in @statuses
        @counts[i][status] ||= {}
      end

      @counts[i]["All Participants"]["US"] = this_scope.where("sp_projects.country = 'United States' AND primary_partner IN(?)", Region.standard_region_codes).count
      
      #    WSN means it's international, country <> 'United States'
      #    US, WSN would be anything from the 10 regions, then Other Ministries would be any other partner that isn't one of the 10 regions regardless of the country
      @counts[i]["All Participants"]["WSN"] = this_scope.where("sp_projects.country <> 'United States' AND primary_partner IN(?)", Region.standard_region_codes).count

      @counts[i]["All Participants"]["Other Ministries"] = this_scope.where("primary_partner NOT IN(?)", Region.standard_region_codes).count
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_participants_to_wsn_sps_by_area
    @headers = [ "East Asia Opportunities", "East Asia Orient", "Eastern Europe/Russia", "Francophone Africa", "Latin America", "NAME", "Nigeria & West Africa",
      "North America and Oceania", "PACT", "South Asia", "SouthEast Asia", "Southern & Eastern Africa", "Western Europe" ]

    @counts = {}
    (0..2).each do |i|
      @extra_query_parts = ""
      if i == 0
        # male
        @extra_query_parts += " AND (gender IN (1, '1'))"
      elsif i == 1
        # female
        @extra_query_parts += " AND (gender IN (0, '0'))"
      end
      @counts ||= {}
      @counts[i] ||= {}
      @counts[i]["All Participants"] = SpApplication.joins(:person).where(:year => @year).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff')#{@extra_query_parts}").group("region").count
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_participants_to_hs_sps
    @headers = [ "Student Venture", "MK2MK" ]

    @counts = {}
    (0..2).each do |i|
      @extra_query_parts = " "
      if i == 0
        # male
        @extra_query_parts += " AND (gender IN (1, '1'))"
      elsif i == 1
        # female
        @extra_query_parts += " AND (gender IN (0, '0'))"
      end
      @counts ||= {}
      @counts[i] ||= {}
      @counts[i][ "All Participants"] = SpApplication.joins(:person).where(:year => @year).where(:'sp_projects.high_school' => true).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff')#{@extra_query_parts}").joins(:project).group("primary_partner").count
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end

  def total_num_participants_to_other_ministry_sps
    @headers = SpProject.connection.select_values("Select distinct(primary_partner) from sp_projects where report_stats_to = 'Other CCC ministry'").reject(&:blank?) - Region.standard_region_codes

    @counts = {}
    SpProject.current.group_by(&:primary_partner).each_pair do |partner, ps|
      (0..2).each do |i|
        @extra_query_parts = ""
        if i == 0
          # male
          @extra_query_parts += " AND (gender IN (1, '1'))"
        elsif i == 1
          # female
          @extra_query_parts += " AND (gender IN (0, '0'))"
        end
        @counts ||= {}
        @counts[i] ||= {}
        @counts[i][ "All Participants"] = SpApplication.joins(:person).where(:year => @year).where("(status = 'accepted_as_participant' OR status = 'accepted_as_student_staff')#{@extra_query_parts}").joins(:project).group("primary_partner").count
      end
    end

    respond_to do |format|
      format.html
      format.csv {
        output_total_num_counts_to_csv
      }
    end
  end
  
  def projects_summary
    @projects = SpProject.current
    @headers = ['Name', '# Weeks', 'Max Participants','Accepted Participants','Accepted Student Staff', '# Staff', 'Student Cost', 'Staff Cost','Primary Partner','Secondary Partner','Tertiary Partner','Project Type','Uses USCM App']
    @rows = @projects.collect {|p| [p.name, p.weeks, p.capacity, p.current_students_men.to_i + p.current_students_women.to_i, p.sp_applications.accepted_student_staff.count, p.staff.count, p.student_cost, p.staff_cost, p.primary_partner, p.secondary_partner, p.tertiary_partner, p.report_stats_to, p.use_provided_application]}
  end
  
  protected
    def output_total_num_counts_to_csv
      csv = ""
      CSV.generate(csv) do |csv|
        row = []
        @headers.each do |h|
          row += [ "", h, "" ]
        end
        csv << row
        row = []
        @headers.each do |h|
          row += [ "Male", "Female", "Total" ]
        end
        csv << row
        for status in @statuses
          row = []
          for header in @headers
            row += [ @counts[0][status][header], @counts[1][status][header], @counts[2][status][header] ]
          end
          csv << row
        end
      end
      render :text => csv
    end

    def set_total_participants_statuses
      @statuses = [ "All Participants" ]
    end

    def set_total_applicant_statuses
      @statuses = [ "Accepted as Participant", "Accepted as Student Staff", "Ready", "Submitted", "Unsubmitted", "Started", 
        "Withdrawn (Accepted as Participant)", "Withdrawn (Accepted as Student Staff)", "Withdrawn (Ready)", "Withdrawn (Submitted)", 
        "Withdrawn (Unsubmitted)", "Withdrawn (Started)", "Withdrawn (No status set)", "Declined" ]
    end

    def get_applications(project)
     SpApplication.preferrenced_project(project.id).for_year(project.year).order('ministry_person.lastName, ministry_person.firstName').includes(:person => :current_address)
    end

    def check_access
      unless sp_user.can_see_reports?
        flash[:error] = "You don't have access to the reports section"
        redirect_to('/admin') and return false
      end
      if %w{regional partner region missional_team school}.include?(params[:action]) && !(sp_user.is_a?(SpRegionalCoordinator) || sp_user.is_a?(SpNationalCoordinator))
        return no_access
      end
      if (%w{national applicants pd_emails student_emails project_start_end fee_by_staff sending_stats stats_by_project projects_summary} + @@total_applicant_actions + @@total_participant_actions).include?(params[:action]) && !(sp_user.is_a?(SpNationalCoordinator))
        return no_access
      end
    end
      
    def no_access
      flash[:error] = 'You don\'t have access to those reports'
      redirect_to(admin_reports_path) and return false
    end

    def year
      #return 2011
      SpApplication::YEAR
      # year = SpProject.maximum(:year)
    end

    def set_year
      @year = params[:year] || year
    end

    def set_years
      @years = (SpApplication.select("distinct year").order("year DESC").collect(&:year).compact + [ year ]).uniq.sort{ |a,b| b <=> a }
    end
end
