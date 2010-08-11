class Admin::ProjectsController < ApplicationController
  layout 'admin'
  def index
    cookies.permanent[:projects_per_page] = params[:projects_per_page] if params[:projects_per_page]
    @per_page = cookies[:projects_per_page] || 20
    @projects = SpProject.current.includes(:apd, :opd, :pd).paginate(:page => params[:page], :per_page => @per_page)
  end
end
