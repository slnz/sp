class ProjectsController < ApplicationController
  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def show
    @project = SpProject.find(params[:id])
    respond_to do |format|
      format.xml {
        if @project.show_on_website? && @project.project_status == "open"
          render :xml => @project.to_xml(serialization_attributes.merge(:cdata => true))
        else
          render :xml => "<sp-project/>"
        end
       }
       format.json { render json: @project.to_json(serialization_attributes.merge(:root => 'project')) }
     end
  end

  def index
      year = params[:year].present? ? params[:year].to_i : SpApplication.year
      conditions = [[],[]]
      conditions[0] << "#{SpProject.table_name}.show_on_website = 1"
      conditions[0] << "(#{SpProject.table_name}.current_students_men + #{SpProject.table_name}.current_students_women) < (#{SpProject.table_name}.max_accepted_men + #{SpProject.table_name}.max_accepted_women)"
      conditions[0] = conditions[0].join(' AND ')
      conditions.flatten!

      if conditions[0].empty?
        @projects = []
      else
        @searched = true
      @projects = SpProject.current
      @projects = @projects.where(conditions)
                           .includes(:primary_ministry_focus, :ministry_focuses)
                           .order('sp_projects.name, sp_projects.year')

      respond_to do |format|
        format.html do
          @projects.reject! {|p| !p.use_provided_application?} if @projects
        end
        format.xml
        format.json { render json: cache(@key, :expires_in => 1.hour) { @projects.to_json(serialization_attributes.merge(:root => 'project')) } }
      end
    end
  end

  protected
    def build_focus_conditions(focus, conditions)
      if focus
        condition = "(#{SpProject.table_name}.primary_ministry_focus_id = ? "
        unless focus.projects.empty?
          condition += "OR #{SpProject.table_name}.id IN (#{focus.projects.collect(&:id).join(',')}))"
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

    def serialization_attributes
      {:only => [:id, :name, :start_date,
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
                                {:only => :name, :methods => []}}}
    end
end

