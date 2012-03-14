class Admin::PeopleController < ApplicationController
  before_filter CASClient::Frameworks::Rails3::Filter, AuthenticationFilter
  before_filter :get_person, :only => [:edit, :destroy, :update, :show]
  respond_to :html, :js
  def show
    @projectID = params[:projID].to_i
    if @person.sp_designation_numbers.where(:project_id => @projectID).count != 0
      @designation = @person.sp_designation_numbers.where(:project_id => @projectID).first
    end
    respond_with(@person)
  end
  
  def update
    @person.update_attributes(params[:person])
    @projectID = params[:projID].to_i
    if @projectID != 0
      if @person.sp_designation_numbers.where(:project_id => @projectID).count != 0
        @designation = @person.sp_designation_numbers.where(:project_id => @projectID).first
        @designation.designation_number = params[:designation_number]
        @designation.save
      else
        @designation = @person.sp_designation_numbers.create(:project_id => @projectID, :designation_number => params[:designation_number])
      end
    end
    respond_with(@person)
  end
  
  protected
    def get_person
      @person = Person.find(params[:id])
    end
end
