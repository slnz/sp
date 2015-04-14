class Admin::PeopleController < ApplicationController
  before_action :cas_filter, :authentication_filter
  before_action :get_person, only: [:edit, :destroy, :update, :show]
  layout 'admin'

  def show
    @project_id = params[:project_id].to_i
    @year = params[:year].to_i
    @application = SpApplication.where(year: params[:year], person_id: @person.id, project_id: @project_id).first
    @designation = @person.sp_designation_numbers.where(project_id: @project_id, year: @year).first
    @person.current_address = @person.create_current_address unless @person.current_address
  end

  def update
    @person.update_attributes!(person_params)
    if person_params[:current_address_attributes]
      @person.current_address ||= @person.create_current_address
      @person.current_address.update_attributes!(person_params[:current_address_attributes])
    end
    @project_id = params[:project_id].to_i
    @year = params[:year].to_i
    @application = SpApplication.where(year: params[:year], person_id: @person.id, project_id: @project_id).first
    if @project_id != 0
      if @designation = @person.sp_designation_numbers.where(project_id: @project_id, year: @year).first
        @designation.update_attributes(designation_number: params[:designation_number])
      else
        @designation = @person.sp_designation_numbers.create(project_id: @project_id, designation_number: params[:designation_number], year: SpApplication.year)
      end
    end
    if params[:sp_application].present? && !(params[:sp_application].is_a?(Hash))
      application_start_date = SpApplication.find(params[:sp_application]).start_date.to_s
      application_end_date = SpApplication.find(params[:sp_application]).end_date.to_s
      start_date = Date.strptime(application_start_date, '%Y-%m-%d')
      end_date = Date.strptime(application_end_date, '%Y-%m-%d')
      @application.start_date = start_date
      @application.end_date = end_date
      @application.save
    end
    respond_to do |wants|
      wants.html { redirect_to admin_person_path(@person) }
      wants.js
    end
  end

  def search_ids
    @people = Person.search_by_name(params[:q])

    respond_to do |wants|
      wants.json { render text: @people.collect(&:id).to_json }
    end
  end

  def merge
    @people = 1.upto(4).collect { |i| Person.find_by_id(params["person#{i}"]) if params["person#{i}"].present? }.compact
  end

  def confirm_merge
    @people = 1.upto(4).collect { |i| Person.find_by_id(params["person#{i}"]) if params["person#{i}"].present? }.compact

    unless @people.length >= 2
      redirect_to merge_admin_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: 'You must select at least 2 people to merge'
      return false
    end
    @keep = @people.delete_at(params[:keep].to_i)
    unless @keep
      redirect_to merge_admin_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: 'You must specify which person to keep'
      return false
    end
    # If any of the other people have users, the keeper has to have a user
    unless @keep.user
      if person = @people.detect(&:user)
        redirect_to merge_admin_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "Person ID# #{person.id} has a user record, but the person you are trying to keep doesn't. You should keep the record with a user."
        return false
      end
    end
  end

  def merge_preview
    render nothing: true and return false unless params[:id].to_i > 0
    @person = Person.find_by_id(params[:id])
    respond_to do |wants|
      wants.js {}
    end
  end

  def do_merge
    @keep = Person.find(params[:keep_id])
    params[:merge_ids].each do |id|
      person = Person.find(id)
      @keep = @keep.smart_merge(person)
    end
    redirect_to merge_admin_people_path, notice: "You've just merged #{params[:merge_ids].length + 1} people"
  end

  protected

  def get_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.fetch(:person, {}).permit(:start_date, :end_date, :first_name, :last_name, :preferred_name, :email, current_address_attributes: [:home_phone, :cell_phone, :work_phone, :email, :address1, :address2, :city, :state, :zip, :country, :id]) # :current_application
  end
end
