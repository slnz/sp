class Admin::LeadersController < ApplicationController
  respond_to :html, :js
  before_filter :load_project, :only => [:destroy, :edit, :update]
  
  def show
    @person = Person.find(params[:id])
    respond_with(@person)
  end
  
  def destroy
    @project.update_attribute(params[:leader] + '_id', nil) if ['apd','pd','opd','coord'].include?(params[:leader])
    respond_with(@project) 
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  protected
  
  def load_project
    @project = SpProject.find(params[:id])
  end
end
