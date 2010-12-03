class Admin::ReportsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter
  layout 'admin'
  def show
    
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

  def female_openings
    @percentages = {'0-50%' => [], '51-99%' => [], '100%' => []}
    SpProject.current.uses_application.order(:name).each do |project|
      case 
      when project.percent_full_women < 50
        @percentages['0-50%'] << project
      when project.percent_full_women < 100
        @percentages['51-99%'] << project
      else
        @percentages['100%'] << project
      end
    end
  end

  protected
    def get_applications(project)
     SpApplication.preferrenced_project(project.id).for_year(project.year).order('ministry_person.lastName, ministry_person.firstName').includes(:person => :current_address)
    end
end
