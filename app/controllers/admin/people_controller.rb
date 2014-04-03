class Admin::PeopleController < ApplicationController
  before_filter :cas_filter, :authentication_filter
  before_filter :get_person, :only => [:edit, :destroy, :update, :show]
  respond_to :html, :js
  def show
    @project_id = params[:project_id].to_i
    @year = params[:year].to_i
    @application = SpApplication.where(year: params[:year], person_id: @person.id, project_id: @project_id).first
    @designation = @person.sp_designation_numbers.where(:project_id => @project_id, :year => @year).first
    @person.current_address = @person.create_current_address unless @person.current_address
    respond_with(@person, @application)
  end

  def update
    @person.update_attributes(person_params)
    @project_id = params[:project_id].to_i
    @year = params[:year].to_i
    @application = SpApplication.where(year: params[:year], person_id: @person.id, project_id: @project_id).first
    if @project_id != 0
      if @designation = @person.sp_designation_numbers.where(:project_id => @project_id, :year => @year).first
        @designation.update_attributes(:designation_number => params[:designation_number])
      else
        @designation = @person.sp_designation_numbers.create(:project_id => @project_id, :designation_number => params[:designation_number], :year => SpApplication.year)
      end
    end
    dates = params[:sp_application]
    if dates.present?
      start_date = Date.strptime(dates[:start_date], "%m/%d/%Y")
      end_date = Date.strptime(dates[:end_date], "%m/%d/%Y")
      @application.start_date = start_date
      @application.end_date = end_date
      @application.save
    end
    respond_to do |wants|
      wants.html { redirect_to admin_person_path(@person) }
      wants.js
    end
  end

  protected
  def get_person
    @person = Person.find(params[:id])
  end
  
  def person_params
    params.fetch(:person, {}).permit(:start_date, :end_date, :firstName, :lastName, :preferredName, current_address_attributes: [:homePhone, :cellPhone, :workPhone, :email, :address1, :address2, :city, :state, :zip, :country, :id]) # :current_application
  end
end