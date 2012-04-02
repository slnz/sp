class Admin::PeopleController < ApplicationController
  before_filter CASClient::Frameworks::Rails3::Filter, AuthenticationFilter
  before_filter :get_person, :only => [:edit, :destroy, :update, :show]
  respond_to :html, :js
  def show
    @project_id = params[:project_id].to_i
    @year = params[:year].to_i
    @designation = @person.sp_designation_numbers.where(:project_id => @project_id, :year => @year).first
    respond_with(@person)
  end
  
  def update
    @person.update_attributes(params[:person])
    @project_id = params[:project_id].to_i
    @year = params[:year].to_i
    if @project_id != 0
      if @designation = @person.sp_designation_numbers.where(:project_id => @project_id, :year => @year).first
        @designation.update_attributes(:designation_number => params[:designation_number])
      else
        @designation = @person.sp_designation_numbers.create(:project_id => @project_id, :designation_number => params[:designation_number], :year => SpApplication::YEAR)
      end
    end
    respond_with(@person)
  end
  
  protected
    def get_person
      @person = Person.find(params[:id])
    end
end
