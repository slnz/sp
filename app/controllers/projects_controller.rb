class ProjectsController < ApplicationController
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  # caches_page :index
  
  def show
    @project = SpProject.find(params[:id])
    respond_to do |format|
      format.xml {
        if @project.show_on_website && @project.project_status == "open"
          render :xml => @project.to_xml(:only => [:id, :name, :start_date,
                                                           :end_date, :weeks,
                                                           :job, :description,
                                                           :display_location,
                                                           :student_cost, :primary_partner,
                                                           :url, :url_title, :updated_at,
                                                           :use_provided_application],
                                                 :methods => [:pd_name, :apd_name,
                                                              :pd_email, :apd_email,
                                                              :primary_focus_name, :description_with_cdata,
                                                              :regional_info],
                                                 :include => {:ministry_focuses =>
                                                              {:only => :name, :methods => []}},
                                          :cdata => true)
        else
          render :xml => "<sp-project/>"
        end
       }
     end
  end
  
  def index
    @key = Digest::SHA1.hexdigest(params.collect {|k,v| [k,v]}.flatten.join('/'))
    unless fragment_exist?(@key)
      unless params.size == 2
        year = params[:year].present? ? params[:year].to_i : SpApplication::YEAR
        conditions = [[],[]]
        conditions[0] << "#{SpProject.table_name}.show_on_website = 1"
        conditions[0] << "(#{SpProject.table_name}.current_students_men + #{SpProject.table_name}.current_students_women + #{SpProject.table_name}.current_applicants_men + #{SpProject.table_name}.current_applicants_women) < (#{SpProject.table_name}.max_student_men_applicants + #{SpProject.table_name}.max_student_women_applicants)"
        unless params[:all] == 'true'
          
          if params[:name] && !params[:name].empty?
            conditions[0] << "#{SpProject.table_name}.name like ?"
            conditions[1] << "%#{params[:name]}%"
          end
          if params[:city] && !params[:city].empty?
            conditions[0] << "#{SpProject.table_name}.city = ?"
            conditions[1] << params[:city]
          end
          if params[:country] && !params[:country].empty?
            countries = params[:country].split(',')
            condition = []
            countries.each do |country|
              condition << "#{SpProject.table_name}.country LIKE ?"
              conditions[1] << '%'+country+'%'
            end
            conditions[0] << '(' + condition.join(' OR ') + ')'
          end
          # this option has two modes of access to accomodate the form post and 
          # the xml feed. params[:project][:partner] is for the form post.
          # params[:partner] is for the xml feed.
          if (params[:partner] || (params[:project] && params[:project][:partner])) && 
                !(partner = params[:partner] || params[:project][:partner]).empty?
            conditions[0] << "(#{SpProject.table_name}.primary_partner = ? OR 
                               #{SpProject.table_name}.secondary_partner = ? OR 
                               #{SpProject.table_name}.tertiary_partner = ?)"
            conditions[1] << partner
            conditions[1] << partner
            conditions[1] << partner
          end
          if params[:world_region] && !params[:world_region].empty?
            world_regions = params[:world_region].split(',')
            condition = []
            world_regions.each do |world_region| 
              condition << "#{SpProject.table_name}.world_region LIKE ?"
              conditions[1] << '%'+world_region+'%'
            end
            conditions[0] << '(' + condition.join(' OR ') + ')'
          end
          if params[:start_month].present?
            day = params[:start_day].present? ? params[:start_day].to_i : 1
            start_date = Time.mktime(year, params[:start_month].to_i, day)
            conditions[0] << "#{SpProject.table_name}.start_date >= ?"
            conditions[1] << start_date.to_s(:db)
          end

          if params[:end_month] && !params[:end_month].empty?
            day = params[:end_day].present? ? params[:end_day].to_i : COMMON_YEAR_DAYS_IN_MONTH[params[:end_month].to_i]
            end_date = Time.mktime(year, params[:end_month].to_i, day)
            conditions[0] << "#{SpProject.table_name}.end_date <= ?"
            conditions[1] << end_date
          elsif params[:start_month].present?
            end_date = Time.mktime(year, 12, 31)
            conditions[0] << "#{SpProject.table_name}.end_date <= ?"
            conditions[1] << end_date
          end
          if params[:project_type] && !params[:project_type].empty?
            conditions[0] << "#{SpProject.table_name}" + get_project_type_condition
          end
          if params[:focus] && params[:focus].to_i != 0
            focus = SpMinistryFocus.find(params[:focus])
            build_focus_conditions(focus, conditions)
          end
          if params[:focus_name] && !params[:focus_name].empty?
            focus = SpMinistryFocus.find_by_name(params[:focus_name])
            build_focus_conditions(focus, conditions)
          end
          if params[:from_weeks] && !params[:from_weeks].empty?
            conditions[0] << "#{SpProject.table_name}.weeks >= ?"
            conditions[1] << params[:from_weeks]
          end
          if params[:to_weeks] && !params[:to_weeks].empty?
            conditions[0] << "#{SpProject.table_name}.weeks <= ?"
            conditions[1] << params[:to_weeks]
          end
          if params[:job] && !params[:job].empty?
            conditions[0] << "#{SpProject.table_name}.job = ?"
            conditions[1] << (params[:job] ? 1 : 0)
          end
        end
        conditions[0] = conditions[0].join(' AND ')
        conditions.flatten!
        if conditions[0].empty?
          @projects = []
        else
          @projects = SpProject.current.find(:all, 
                                      :include => [:primary_ministry_focus, :ministry_focuses],
                                      :conditions => conditions,
                                      :order => 'sp_projects.name, sp_projects.year')
        end
      end
      respond_to do |format|
        format.html do
          @projects.reject! {|p| !p.use_provided_application?} if @projects
        end
        format.xml 
      end
    end
  end
  
  protected
    def build_focus_conditions(focus, conditions)
      if focus
        condition = "(#{SpProject.table_name}.primary_ministry_focus_id = ? "
        unless focus.sp_projects.empty?
          condition += "OR #{SpProject.table_name}.id IN (#{focus.sp_projects.collect(&:id).join(',')}))"
        else
          condition += ")"
        end
        conditions[0] << condition
        conditions[1] << focus.id
      end
    end
    
    def get_regions
      @region_options = Region.find(:all, :order => 'region').map(&:region)
    end
    
    def get_project_type_condition
      if params[:project_type] == 'US'
        return ".country = 'United States'"
      else
        return ".country <> 'United States'"
      end
    end
end

