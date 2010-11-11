class Admin::ProjectsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, AuthenticationFilter, :check_sp_user, :except => :no
  uses_tiny_mce :options => {:theme => 'advanced',
                             :theme_advanced_buttons1 => "bold,italic,underline,separator,strikethrough,justifyleft,justifycenter,justifyright,justifyfull,bullist,numlist,undo,redo,link,unlink",
                             :theme_advanced_buttons2 => "",
                             :theme_advanced_buttons3 => "",
                             :theme_advanced_toolbar_location => "top",
                             :theme_advanced_toolbar_align => "left"}
  before_filter :get_project, :only => [:edit, :destroy, :update, :close, :open, :show, :email, :download, :send_email]
  before_filter :get_year, :only => [:show, :email, :edit]
  before_filter :get_countries, :only => [:new, :edit, :update, :create]
  cache_sweeper :project_sweeper 
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
    initialize_questions
    (3 - @project.student_quotes.length).times do 
      @project.student_quotes.build
    end
  end
  
  def update
    update_questions
    @project.update_attributes(params[:sp_project])
    respond_with(@project) do |format|
      format.html {@project.errors.empty? ? redirect_to(dashboard_path, :notice => "#{@project} project was updated successfully.") : render(:edit)}
    end
  end
  
  def create
    @project = SpProject.create(params[:sp_project].merge({:year => SpApplication::YEAR}))
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
    
    [@project.pd(year), @project.apd(year), @project.opd(year), @project.coordinator(year)].each do |person|
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
    sheet1.row(r += 1).concat(["Staff and Volunteers:"])
    
    
    sheet1.row(r += 1).concat(staff_column_headers)
    
    @project.staff_and_volunteers(year).each do |person|
    
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
     "Birthday", 'Age', "Accepted On", "Email", "Address", "Address2", "City", "State",
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
    @group_options = [['',''],['Staff/Interns + Accepted Students (Team)','team'],['All Applicants (except withdrawn/denied)','all_applicants'],
                  ['All Accepted Students','all_accepted'],['Accepted Men','accepted_men'],['Accepted Women','accepted_women'],
                  ['Pending Students','pending_students'],['All Staff and Interns','staff_and_interns'],
                  ['Men Staff and Interns','men_staff_and_interns'],['Women Staff and Interns','women_staff_and_interns']]
    @group_options << ['Parent References','parent_refs'] if @project.primary_partner == 'MK2MK'
    build_email_hash
  end

  def send_email
    if params[:from].blank?
      flash[:notice] = 'You must specify a "From" address'
      redirect_to :back
    else
      to = params[:to].split(/,|;/)
      to.each do |t|
        t.strip!
      end
      cc = params[:from]
      files = (params[:file] || {}).values
      email = ProjectMailer.team_email(to, cc, params[:from], files.compact, params[:subject], params[:body]).deliver
      redirect_to admin_project_path(@project), :notice => "Your email has been sent"
    end
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
      @base = @base.where(:id => current_person.current_staffed_projects.collect(&:id))
    when 'SpRegionalCoordinator'
      @base = @base.where("primary_partner IN(?) OR secondary_partner IN(?) OR tertiary_partner IN(?)", sp_user.partnerships, sp_user.partnerships, sp_user.partnerships) if sp_user.partnerships.present?
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
    values["Age"] = person.birth_date.present? ? ((Date.today.to_time - person.birth_date.to_time) / 1.year).floor : ''
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
  
  def build_email_hash
    @emails = {}
    @group_options.each do |group|
      next if group[1].blank?
      addresses = []
      case group[1]
      when 'all_applicants'
        applicant_conditions = "status NOT IN ('declined', 'withdrawn')"
        include_applicants = true
      when 'all_accepted'
        applicant_conditions = "status IN ('accepted_as_intern', 'accepted_as_participant')"
        include_applicants = true
      when 'accepted_men'
        applicant_conditions = "status IN ('accepted_as_intern', 'accepted_as_participant') AND ministry_person.gender = 1"
        include_applicants = true
      when 'accepted_women'
        applicant_conditions = "status IN ('accepted_as_intern', 'accepted_as_participant') AND ministry_person.gender = 0"
        include_applicants = true
      when 'pending_students'
        applicant_conditions = "status IN ('started', 'submitted')"
        include_applicants = true
      when 'staff_and_interns'
        applicant_conditions = "status IN ('accepted_as_intern')"
        include_applicants = true
        include_staff = true
      when 'men_staff_and_interns'
        applicant_conditions = "status IN ('accepted_as_intern') AND ministry_person.gender = 1"
        include_applicants = true
        include_staff = true
      when 'women_staff_and_interns'
        applicant_conditions = "status IN ('accepted_as_intern') AND ministry_person.gender = 0"
        include_applicants = true
        include_staff = true
      when 'parent_refs'
        include_applicants = false
        include_staff = false
        parent_refs = true
      else
        applicant_conditions = "status IN ('accepted_as_intern', 'accepted_as_participant')"
        include_staff = true
        include_applicants = true
      end
      people = []
      if include_applicants
        accepted_applications = SpApplication.find(:all, :conditions => ["#{applicant_conditions} and (project_id = ? OR (preference1_id = ? AND (project_id IS NULL OR project_id = ?))) and year = ?", @project.id, @project.id, @project.id, @year], :include => :person)
        accepted_applications.each do |app|
          people << app.person
        end
      end
      if include_staff
        # Men, women or all
        case params[:group]
        when 'men_staff_and_interns'
          people += [@project.pd(@year)] if @project.pd(@year).is_male?
          people += [@project.apd(@year)] if @project.apd(@year).is_male?
          people += [@project.opd(@year)] if @project.opd(@year).is_male?
          people += @project.staff(@year).where(:gender => 1) 
          people += @project.volunteers(@year).where(:gender => 1)
        when 'women_staff_and_interns'
          people += [@project.pd(@year)] if !@project.pd(@year).is_male?
          people += [@project.apd(@year)] if !@project.apd(@year).is_male?
          people += [@project.opd(@year)] if !@project.opd(@year).is_male?
          people += @project.staff(@year).where(:gender => 0)
          people += @project.volunteers(@year).where(:gender => 0)
        else
          people += [@project.pd(@year)] + [@project.apd(@year)] + [@project.opd(@year)] + @project.staff(@year) + @project.volunteers(@year) 
        end
      end
    
      if parent_refs
        addresses = SpParentReference.find(:all, :conditions => ["application_id = sp_applications.id AND project_id = ?", @project.id], :include => :sp_application).collect(&:email)
        addresses.reject!(&:blank?)
        addresses.uniq!
      else
        people.each do |person|
          if person
            email = person.email_address
            if email
              addresses << person.informal_full_name + " <" + email + ">";
            end
          end
        end
      end
      @emails[group[1]] = addresses.join(",\n")
    end

    @from = current_user.person.current_address.try(:email).to_s
  end

  protected
    def initialize_questions
      @custom_page = @project.initialize_project_specific_question_sheet.pages.first
      @questions = @custom_page.elements.to_a
      (5 - @questions.length).times do 
        @questions << TextField.new
      end
    end
    
    def update_questions
      if params[:questions].present?
        initialize_questions
        params[:questions].each do |i, attribs|
          if attribs[:id].present? && question = Element.find_by_id(attribs[:id])
            if attribs[:label].present?
              question.update_attribute(:label, attribs[:label])
            else
              question.destroy
            end
          else
            if attribs[:label].present?
              e = TextField.create!(:label => attribs[:label])
              PageElement.create!(:element_id => e.id, :page_id => @custom_page.id)
            end
          end
        end
        # Set up the questions again after updating them.
        initialize_questions 
      end
    end
end
