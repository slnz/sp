class ProjectsController < ApplicationController
  caches_page :index
  
  def show
    @project = SpProject.find(params[:id])
    respond_to do |format|
      format.xml {
        if @project.show_on_website && @project.project_status == "open"
          render :xml => @project.to_xml(:only => [:name, :start_date,
                                                           :end_date, :weeks,
                                                           :job, :description,
                                                           :display_location,
                                                           :student_cost, :primary_partner,
                                                           :url, :url_title, :updated_at],
                                                 :methods => [:pd_name, :apd_name,
                                                              :pd_email, :apd_email,
                                                              :primary_focus_name,
                                                              :regional_info],
                                                 :include => {:ministry_focuses =>
                                                              {:only => :name, :methods => []}})
        else
          render :xml => "<sp-project/>"
        end
       }
     end
  end
  
  def index
    respond_to do |format|
      format.xml do
        @projects = SpProject.current.all
        render :xml => @projects.to_xml(:only => [:id, :name, :start_date,
                                                           :end_date, :weeks,
                                                           :job, :description,
                                                           :display_location,
                                                           :student_cost, :primary_partner,
                                                           :url, :url_title, :updated_at, :longitude, :latitude],
                                                 :methods => [:pd_name, :apd_name,
                                                              :pd_email, :apd_email,
                                                              :primary_focus_name,
                                                              :regional_info, :percent_full,
                                                              :color, :international],
                                                 :include => {:ministry_focuses => {:only => :name, :methods => []}})
      end
    end
  end
end
