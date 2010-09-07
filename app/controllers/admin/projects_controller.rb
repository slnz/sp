class Admin::ProjectsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter, :check_valid_user, :except => :no
  uses_tiny_mce :options => {:theme => 'advanced',
                             :theme_advanced_buttons1 => "bold,italic,underline,separator,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,undo,redo,link,unlink",
                             :theme_advanced_buttons2 => "",
                             :theme_advanced_buttons3 => "",
                             :theme_advanced_toolbar_location => "top",
                             :theme_advanced_toolbar_align => "left"}
  before_filter :get_project, :only => [:edit, :destroy, :update, :close, :open, :show, :email, :download]
  before_filter :get_year, :only => [:show, :email]
  before_filter :get_countries, :only => [:new, :edit, :update, :create]
  respond_to :html, :js
  
  layout 'admin'
  def index
    set_up_pagination
    set_up_filters
    set_order
    @projects = @base.includes([:sp_staff]).paginate(:page => params[:page], :per_page => @per_page)
    respond_with(@products)
  end
  
  def edit
    (5 - @project.student_quotes.length).times do 
      @project.student_quotes.build
    end
  end
  
  def update
    @project.update_attributes(params[:sp_project])
    respond_with(@project) do |format|
      format.html {@project.errors.empty? ? redirect_to(dashboard_path, :notice => "#{@project} project was updated successfully.") : render(:edit)}
    end
  end
  
  def create
    @project = SpProject.create(params[:sp_project])
    respond_with(@project) do |format|
      format.html do
        if @project.new_record?
          render :new
        else
          redirect_to admin_projects_path, :notice => "#{@project} project was created successfully."
        end
      end
    end
  end
  
  def destroy
    @project.destroy if sp_user.can_delete_project?
    respond_with(@project) do |format|
      format.html do
        redirect_to admin_projects_path, :notice => "#{@project} project was created deleted."
      end
    end
  end
  
  def show
    applications = @project.sp_applications.joins(:person).includes({:person => :current_address}).order('lastName, firstName')
    @accepted_participants = applications.accepted_participants.for_year(@year)
    @accepted_interns = applications.accepted_interns.for_year(@year)
    @ready_to_evaluate = applications.ready_to_evaluate.for_year(@year)
    @submitted = applications.submitted.for_year(@year)
    @not_submitted = applications.not_submitted.for_year(@year)
    @not_going = applications.not_going.for_year(@year)
  end
  
  def download
    year = params[:year] || SpApplication::YEAR
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = "attachment; filename=\"#{@project.name} - Roster - #{year}.xls\""
    headers['Cache-Control'] = ''
    
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(:name => @project.name)
    
    r = -1

    sheet1.row(r += 1).concat([@project.name])

    sheet1.row(r += 1).concat([ "City:", @project.city])
    sheet1.row(r += 1).concat([ "Country:", @project.country])
    sheet1.row(r += 1).concat([ "Primary partner:", @project.primary_partner])
    sheet1.row(r += 1).concat([ "Secondary partner:", @project.secondary_partner]) if @project.secondary_partner.present?
    sheet1.row(r += 1).concat([ "Tertiary partner:", @project.tertiary_partner]) if @project.tertiary_partner.present?
    sheet1.row(r += 1).concat([ "Staff Start Date:", (@project.staff_start_date || "N/A").to_s])
    sheet1.row(r += 1).concat([ "Staff End Date:", (@project.staff_end_date || "N/A").to_s])
    sheet1.row(r += 1).concat([ "Student Start Date:", (@project.start_date || "N/A").to_s])
    sheet1.row(r += 1).concat([ "Student Stop Date:", (@project.end_date || "N/A").to_s])
    staff_column_headers =  ["First Name", "Last Name", "Preferred Name", "Gender",
     "Birthday", "Email", "Address", "Address2", "City", "State",
     "Zip", "Phone", "Cell", "Campus", "AccountNo", "Marital Status",
     "Emergency Contact", "Emergency Relationship",  "Emergency Address", "Emergency City", "Emergency State",
     "Emergency Zip", "Emergency Phone", "Emergency WorkPhone", "Emergency Email"];
     
    sheet1.row(r += 1).concat([])
    sheet1.row(r += 1).concat(["Directors:"])
    sheet1.row(r += 1).concat(staff_column_headers)
    
    [@project.pd, @project.apd, @project.opd, @project.coordinator].each do |person|
      unless person.nil?
        row = []
        values = set_values_from_person(person)
        staff_column_headers.each do |header|
          if (values[header] && values[header] != "")
            row << values[header].to_s.gsub(/[\t\r\n]/, " ")
          else
            row << "N/A"
          end
        end
        sheet1.row(r += 1).concat(row)
      end
    end
    
    sheet1.row(r += 1).concat([])
    sheet1.row(r += 1).concat(["Staff:"])
    
    
    sheet1.row(r += 1).concat(staff_column_headers)
    
    @project.staff.each do |person|
    
      values = set_values_from_person(person)
    
      row = []
      staff_column_headers.each do |header|
        if (values[header] && values[header] != "")
          row << values[header].to_s.gsub(/[\t\r\n]/, " ")
        else
          row << "N/A"
        end
      end
      sheet1.row(r += 1).concat(row)
    end
    
    sheet1.row(r += 1).concat([])
    sheet1.row(r += 1).concat([ "Accepted Applicants:"])
    
    applicant_column_headers = ["First Name", "Last Name", "Preferred Name", "Gender",
     "Birthday", "Accepted On", "Email", "Address", "Address2", "City", "State",
     "Zip", "Phone", "Cell", "Campus", "Designation No", "Marital Status",
     "Emergency Contact", "Emergency Relationship", "Emergency Address", "Emergency City", "Emergency State",
     "Emergency Zip", "Emergency Phone", "Emergency Work Phone", "Emergency Email",
     "Participant's Campus Region", "Date Became A Christian", "Major", "Class",
     "GraduationDate", "Applied for leadership"]
    
    sheet1.row(r += 1).concat(applicant_column_headers)
    applications = SpApplication.find(:all, :conditions => ["status IN ('accepted_as_intern', 'accepted_as_participant') and project_id = ? and year = ?", @project.id, year], :include => :person )
    
    applications.each do |app|
      values = set_values_from_person(app.person)
      values["Applied for leadership"] = app.apply_for_leadership.to_s
      row = []
      applicant_column_headers.each do |header|
        if (values[header] && values[header] != "")
            row << values[header].to_s.gsub(/[\t\r\n]/, "").gsub(/,/, " ")
        else
          row << "N/A"
        end
      end
      sheet1.row(r += 1).concat(row)
    end
    sio = StringIO.new
    book.write(sio)
    render(:text => sio.string )
  end
  
  def dashboard
    redirect_to dashboard_path
  end
  
  def no
    
  end

  def close
    @project.close!
    redirect_to :back, :notice => "#{@project.name} has been closed."
  end

  def open
    if @project.valid?
      @project.open!
      redirect_to :back, :notice => "#{@project.name} has been re-opened."
    else
      redirect_to edit_admin_project_path(@project), :notice => 'Please update all necessary fields for this project, then try Re-Opening it again.'
    end
  end
  
  def new
    @project = SpProject.new
    5.times do 
      @project.student_quotes.build
    end
  end
  
  def email
  end
  
  def threads
     ActiveRecord::Base.connection.select_all("select sleep(1)")
    render :text => "Oh hai"
  end
  
  def send_email
    
  end
  
  protected 
  def get_project
    @project = SpProject.find(params[:id])
  end
  
  def set_up_pagination
    cookies.permanent[:projects_per_page] = params[:projects_per_page] if params[:projects_per_page]
    @per_page = cookies[:projects_per_page] || 20
  end
  
  def set_up_filters
    @base = params[:closed] ? SpProject : SpProject.current
    @filter_title = 'All'
    if params[:partners]
      @base = @base.where("primary_partner IN(?) OR secondary_partner IN(?) OR tertiary_partner IN(?)", params[:partners], params[:partners], params[:partners])
      @filter_title = params[:partners].sort.join(', ')
    end
    case
    when params[:search].present?
      @base = @base.where("name like ?", "%#{params[:search]}%")
    when params[:search_pd].present?
      @base = @base.pd_like(params[:search_pd])
    when params[:search_apd].present?
      @base = @base.apd_like(params[:search_apd])
    when params[:search_opd].present?
      @base = @base.opd_like(params[:search_opd])
    end
    
    # Filter based on the user type
    case sp_user.class.to_s
    when 'SpDirector', 'SpProjectStaff', 'SpEvaluator'
      @base = @base.where(:id => current_person.staffed_projects.collect(&:id))
    when 'SpRegionalCoordinator'
      @base = @base.where("primary_partner = ? OR secondary_partner = ? OR tertiary_partner = ?", current_person.region, current_person.region, current_person.region)
    when 'SpNationalCoordinator'
    else
      @base = @base.where('1 <> 1')
    end
  end
  
  def set_order
    params[:order] = 'name' and params[:direction] = 'ascend' unless params[:order] && params[:direction]
    @base = @base.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym) 
  end

  def get_countries
    @countries = Country.find(:all, :order => :country)
  end
  
  def get_year
    @year = params[:year].present? ? params[:year] : SpApplication::YEAR
  end

  def set_values_from_person(person)
    values = Hash.new
    values["First Name"] = person.firstName
    values["Last Name"] = person.lastName
    values["Preferred Name"] = person.preferredName
    values["Gender"] = person.gender == "1" ? "M" : "F"
    values["Birthday"] = person.birth_date.present? ? l(person.birth_date) : ''
    values["Accepted On"] = (person.current_application && person.current_application.accepted_at.present? ? l(person.current_application.accepted_at) : '')
    if (person.current_address)
      values["Email"] = person.current_address.email
      values["Address"] = person.current_address.address1
      values["Address2"] = person.current_address.address2
      values["City"] = person.current_address.city
      values["State"] = person.current_address.state
      values["Zip"] = person.current_address.zip
      values["Phone"] = person.current_address.homePhone
      values["Cell"] = person.current_address.cellPhone
    end
    values["Campus"] = person.campus
    values["AccountNo"] = person.accountNo
    values["Designation No"] = person.current_application.try(:designation_number)
    values["Marital Status"] = person.maritalStatus
    if (person.emergency_address)
      values["Emergency Contact"] = person.emergency_address.contactName
      values["Emergency Relationship"] = person.emergency_address.contactRelationship
      values["Emergency Address"] = person.emergency_address.address1
      values["Emergency City"] = person.emergency_address.city
      values["Emergency State"] = person.emergency_address.state
      values["Emergency Zip"] = person.emergency_address.zip
      values["Emergency Phone"] = person.emergency_address.homePhone
      values["Emergency Work Phone"] = person.emergency_address.workPhone
      values["Emergency Email"] = person.emergency_address.email
    end
    values["Participant's Campus Region"] = person.region
    values["Date Became A Christian"] = person.date_became_christian.present? ? l(person.date_became_christian) : ''
    values["Major"] = person.major
    values["Class"] = person.yearInSchool
    values["GraduationDate"] = person.graduation_date.present? ? l(person.graduation_date) : ''
    values
  end

end
