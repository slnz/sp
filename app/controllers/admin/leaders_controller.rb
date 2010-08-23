class Admin::LeadersController < ApplicationController
  respond_to :html, :js
  before_filter :load_project, :only => [:destroy, :edit, :update, :create]
  
  def show
    @person = Person.find(params[:id])
    respond_with(@person)
  end
  
  def destroy
    @project.update_attribute(params[:leader] + '_id', nil) if ['apd','pd','opd','coord'].include?(params[:leader])
    respond_with(@project) 
  end
  
  def create
    @project.update_attribute(params[:leader] + '_id', params[:person_id]) if ['apd','pd','opd','coordinator'].include?(params[:leader])
    respond_with(@project) 
  end
  
  def search
    if params[:name].present?
      term = '%' + params[:name] + '%'
      conditions = ["firstName like ? OR lastName like ? OR concat(firstname, ' ', lastname) like ?", term, term, params[:name] + '%']
      @people = Person.where(conditions).includes(:user).limit(10)
      @total = Person.where(conditions).count
      respond_with(@people) do |format|
        format.js {render :layout => false}
      end
    else
      render :nothing => true
    end
  end
  
  protected
  
  def load_project
    @project = SpProject.find(params[:id] || params[:project_id])
  end
end
