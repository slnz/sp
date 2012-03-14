class Admin::LeadersController < ApplicationController
  before_filter CASClient::Frameworks::Rails3::Filter, AuthenticationFilter
  respond_to :html, :js
  before_filter :load_project, :only => [:destroy, :edit, :update, :create, :add_person]
  
  def new
    names = params[:name].to_s.split(' ')
    @person = Person.new(:firstName => names[0], :lastName => names[1..-1].join(' '))
    @person.current_address = CurrentAddress.new
  end
  
  def destroy
    @person = Person.find(params[:person_id])
    @year = params[:year].present? ? params[:year] : @project.year
    staff = @project.sp_staff.where(:type => params[:leader], :year => @year, :person_id => params[:person_id]).first
    staff.destroy
    respond_with(@project) 
  end
  
  def create
    @year = params[:year].present? ? params[:year] : @project.year
    @person ||= Person.find(params[:person_id]) if params[:person_id]
    if ['apd','pd','opd','coordinator'].include?(params[:leader])
      @project.send(params[:leader] + '=', @person.id)
      @project.save(:validate => false)
    elsif ['staff','kid','evaluator', 'volunteer', 'non_app_participant'].include?(params[:leader])
      @project.sp_staff.create(:type => params[:leader].titleize, :year => @year, :person_id => @person.id)
    end
    render :create
  end
  
  def search
    super
  end
  
  def add_person
    params[:person] ||= {}
    params[:person][:current_address] ||= {}
    @current_address = CurrentAddress.new(params[:person].delete(:current_address).merge({:addressType => 'current'}))
    @person = Person.new(params[:person])
    @person.current_address = @current_address
    required_fields = [@person.firstName, @person.lastName, @person.gender]
    required_fields += [@current_address.homePhone, @current_address.email] unless params[:leader] == 'kid'
    unless required_fields.all?(&:present?) && @person.valid? && @current_address.valid?
      flash[:error] = "Please fill in all fields"
      errors = @person.errors.full_messages + @current_address.errors.full_messages
      flash[:error] = errors.join("<br />") if errors.present?
      render :new and return
    end
    @person.save!
    create and return
  end
  
  protected
  
  def load_project
    @project = SpProject.find(params[:id] || params[:project_id])
  end
end
