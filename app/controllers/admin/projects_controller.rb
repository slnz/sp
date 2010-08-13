class Admin::ProjectsController < ApplicationController
  #uses_tiny_mce :options => {:theme_simple_toolbar_location => 'top'}
  before_filter :get_project, :only => [:edit, :destroy, :update, :close]
  respond_to :html, :js
  
  layout 'admin'
  def index
    set_up_pagination
    set_up_filters
    set_order
    @projects = @base.paginate(:page => params[:page], :per_page => @per_page)
    respond_with(@products)
  end
  
  def edit
    
  end
  
  def create
    @project = SpProject.create(params[:sp_project])
    respond_with(@project)
  end
  
  def dashboard
    if sp_user.can_see_dashboard?
      redirect_to admin_projects_path
    elsif current_person.directs_projects.length > 0
      redirect_to project_path(person.directs_projects.first)
    else
      redirect_to '/'
    end
  end

  def close
    @project.close!
    redirect_to admin_projects_path, :notice => "#{@project.name} has been closed."
  end
  
  def new
    @project = SpProject.new
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
    if params[:search]
      @base = @base.where("name like ?", "%#{params[:search]}%")
    end
  end
  
  def set_order
    params[:order] = 'name' and params[:direction] = 'ascend' unless params[:order] && params[:direction]
    @base = @base.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym) 
  end
end
