class Admin::ProjectsController < ApplicationController
  layout 'admin'
  def index
    if params[:projects_per_page]
      cookies.delete(:projects_per_page)
      cookies.permanent[:projects_per_page] = params[:projects_per_page] 
    end
    raise cookies[:projects_per_page].inspect
    @per_page = cookies[:projects_per_page] || 20
    raise @per_page.inspect
    @projects = SpProject.current.includes(:apd, :opd, :pd).paginate(:page => params[:page], :per_page => @per_page)
  end
end
