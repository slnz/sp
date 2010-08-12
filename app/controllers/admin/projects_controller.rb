class Admin::ProjectsController < ApplicationController
  uses_tiny_mce
  
  before_filter :get_project, :only => [:edit, :destroy, :update]
  layout 'admin'
  def index
    set_up_pagination
    set_up_filters
    @projects = @base.includes(:apd, :opd, :pd).paginate(:page => params[:page], :per_page => @per_page)
  end
  
  def edit
    
  end
  
  def dashboard
    redirect_to admin_projects_path
  end
  
  protected 
  def get_project
    @project = SpProject.find(params[:id])
  end
  
  def set_up_pagination
    cookies.permanent[:projects_per_page] = params[:projects_per_page] if params[:projects_per_page]
    @per_page = cookies[:projects_per_page] || 20
  end
  
  def set_up_filters
    @base = params[:closed] ? SpProject : SpProject.current
    @filter_title = 'All'
    if params[:partners]
      @base = @base.where("primary_partner IN(?) OR secondary_partner IN(?) OR tertiary_partner IN(?)", params[:partners], params[:partners], params[:partners])
      @filter_title = params[:partners].sort.join(', ')
    end
  end
end
