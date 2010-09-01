class Admin::ProjectsController < ApplicationController
  uses_tiny_mce :options => {:theme => 'advanced',
                             :theme_advanced_buttons1 => "bold,italic,underline,separator,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,undo,redo,link,unlink",
                             :theme_advanced_buttons2 => "",
                             :theme_advanced_buttons3 => "",
                             :theme_advanced_toolbar_location => "top",
                             :theme_advanced_toolbar_align => "left"}
  before_filter :get_project, :only => [:edit, :destroy, :update, :close, :open, :show, :email]
  before_filter :get_year, :only => [:show, :email]
  before_filter :get_countries, :only => [:new, :edit, :update, :create]
  respond_to :html, :js
  
  layout 'admin'
  def index
    set_up_pagination
    set_up_filters
    set_order
    @projects = @base.includes([:sp_staff]).paginate(:page => params[:page], :per_page => @per_page)
    respond_with(@products)
  end
  
  def edit
    (5 - @project.student_quotes.length).times do 
      @project.student_quotes.build
    end
  end
  
  def update
    @project.update_attributes(params[:sp_project])
    respond_with(@project) do |format|
      format.html {@project.errors.empty? ? redirect_to(admin_projects_path, :notice => "#{@project} project was updated successfully.") : render(:edit)}
    end
  end
  
  def create
    @project = SpProject.create(params[:sp_project])
    respond_with(@project) do |format|
      format.html do
        if @project.new_record?
          render :new
        else
          redirect_to admin_projects_path, :notice => "#{@project} project was created successfully."
        end
      end
    end
  end
  
  def destroy
    @project.destroy if sp_user.can_delete_project?
    respond_with(@project) do |format|
      format.html do
        redirect_to admin_projects_path, :notice => "#{@project} project was created deleted."
      end
    end
  end
  
  def show
    applications = @project.sp_applications.joins(:person).includes({:person => :current_address}).order('lastName, firstName')
    @accepted_participants = applications.accepted_participants.for_year(@year)
    @accepted_interns = applications.accepted_interns.for_year(@year)
    @ready_to_evaluate = applications.ready_to_evaluate.for_year(@year)
    @submitted = applications.submitted.for_year(@year)
    @not_submitted = applications.not_submitted.for_year(@year)
    @not_going = applications.not_going.for_year(@year)
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
    redirect_to :back, :notice => "#{@project.name} has been closed."
  end

  def open
    if @project.valid?
      @project.open!
      redirect_to :back, :notice => "#{@project.name} has been re-opened."
    else
      redirect_to edit_admin_project_path(@project), :notice => 'Please update all necessary fields for this project, then try Re-Opening it again.'
    end
  end
  
  def new
    @project = SpProject.new
    5.times do 
      @project.student_quotes.build
    end
  end
  
  def email
    
  end
  
  def send_email
    
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
    case
    when params[:search].present?
      @base = @base.where("name like ?", "%#{params[:search]}%")
    when params[:search_pd].present?
      @base = @base.pd_like(params[:search_pd])
    when params[:search_apd].present?
      @base = @base.apd_like(params[:search_apd])
    when params[:search_opd].present?
      @base = @base.opd_like(params[:search_opd])
    end
  end
  
  def set_order
    params[:order] = 'name' and params[:direction] = 'ascend' unless params[:order] && params[:direction]
    @base = @base.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym) 
  end

  def get_countries
    @countries = Country.find(:all, :order => :country)
  end
  
  def get_year
    @year = params[:year].present? ? params[:year] : SpApplication::YEAR
  end
end
