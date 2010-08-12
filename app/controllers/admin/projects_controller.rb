class Admin::ProjectsController < ApplicationController
  before_filter :get_project, :only => [:edit, :destroy, :update]
  layout 'admin'
  def index
    cookies.permanent[:projects_per_page] = params[:projects_per_page] if params[:projects_per_page]
    @per_page = cookies[:projects_per_page] || 20
    @projects = SpProject.current.includes(:apd, :opd, :pd).paginate(:page => params[:page], :per_page => @per_page)
  end
  
  def edit
    
  end
  
  protected 
  def get_project
    @project = SpProject.find(params[:id])
  end
end
