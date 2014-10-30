class Admin::LeadersController < ApplicationController
  before_filter :cas_filter, :authentication_filter
  before_filter :load_project, :only => [:destroy, :edit, :update, :create, :add_person]

  def new
    names = params[:name].to_s.split(' ')
    @person = Person.new(:first_name => names[0], :last_name => names[1..-1].join(' '))
    @person.current_address = CurrentAddress.new
  end

  def destroy
    @person = Person.find(params[:person_id])
    @year = params[:year].present? ? params[:year] : @project.year
    type = %w(apd pd opd).include?(params[:leader]) ? params[:leader].upcase : params[:leader].titleize
    staff = @project.sp_staff.where(:type => type, :year => @year, :person_id => params[:person_id]).first
    staff.destroy if staff
    respond_to do |wants|
      wants.js
    end
  end

  def create
    @year = params[:year].present? ? params[:year] : @project.year
    @person ||= Person.find(params[:person_id]) if params[:person_id]
    if ['apd','pd','opd','coordinator'].include?(params[:leader])
      @project.send(params[:leader] + '=', @person.id)
      @project.save(:validate => false)
    elsif ['staff','kid','evaluator', 'volunteer', 'non_app_participant'].include?(params[:leader])
      @project.sp_staff.create(:type => params[:leader].upcase, :year => @year, :person_id => @person.id)
    end
    render :create
  end

  def search
    super
  end

  def add_person
    #@current_address = CurrentAddress.new(params[:person].delete(:current_address).merge({:address_type => 'current'}))
    @person = Person.new(person_params)
    @person.current_address ||= CurrentAddress.new(address_type: 'current')
    @current_address = @person.current_address
    #@person.current_address = @current_address
    required_fields = [@person.first_name, @person.last_name, @person.gender]
    required_fields += [@current_address.home_phone, @current_address.email] unless params[:leader] == 'kid'
    unless required_fields.all?(&:present?) && @person.valid? && @current_address.valid?
      flash[:error] = "Please fill in all fields"
      @errors = @person.errors.full_messages + @current_address.errors.full_messages
      flash[:error] = @errors.join("<br />") if @errors.present?
      render :new and return
    end
    @person.save!
    create and return
  end

  protected

  def load_project
    @project = SpProject.find(params[:id] || params[:project_id])
  end

  def person_params
    params.fetch(:person, {}).permit(:first_name, :last_name, :gender, current_address_attributes: [:email, :home_phone, :address_type])
  end
end
