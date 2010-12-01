class Admin::ApplicationsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  respond_to :html, :js
  
  layout 'admin'
  
  def search
    set_up_search_form
  end
  
  def search_results
    set_up_search_form
    conditions = [[],[]]
    if params[:first_name] && !params[:first_name].empty?
      conditions[0] << "#{Person.table_name}.firstName like ?"
      conditions[1] << "%#{params[:first_name]}%"
    end
    if params[:last_name] && !params[:last_name].empty?
      conditions[0] << "#{Person.table_name}.lastName like ?"
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
      @schools = TargetArea.joins(:ministry_activities).where('ministry_activity.fk_teamID' => params[:team]).map(&:name)
      if @schools.empty?
        conditions[0] << " 1 <> 1 "
      else
        conditions[0] << "#{Person.table_name}.campus IN (\"#{@schools.join("\",\"")}\")"
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
    conditions.flatten!
    if conditions[0].empty?
      flash[:notice] = "You must use at least one search criteria."
      redirect_to search_admin_applications_path
    else
      @applications = SpApplication.where(conditions).includes([:project, {:person => :current_address}]).order("#{SpApplication.table_name}.year desc, ministry_person.lastName, ministry_person.firstName").paginate(:page => params[:page])
    end
  end
  
  def donations
    @application = SpApplication.includes(:person, :donations).find(params[:id])
  end
  
  protected
    def set_up_search_form
      @region_options = Region.order('region')
      @team_options = MinistryLocalLevel.where("lane = 'FS'").order('name')
      @school_options = TargetArea.select("DISTINCT(name)").where("country = 'USA'").order('name')
      @project_options = SpProject.current.order(:name)
    end
    
    def get_project_type_condition
      if params[:project_type] == 'US'
        return ".country = 'United States'"
      else
        return ".country <> 'United States'"
      end
    end
end
