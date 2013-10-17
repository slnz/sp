require 'csv'
class Admin::ProjectsController < ApplicationController
  before_filter :cas_filter, :authentication_filter, :check_sp_user, :except => :no

  before_filter :get_project, :only => [:edit, :destroy, :update, :close, :open, :show, :email, :download, :send_email]
  before_filter :get_year, :only => [:show, :email, :edit]
  before_filter :get_countries, :only => [:new, :edit, :update, :create]
  respond_to :html, :js

  layout 'admin'
  def index
    set_up_pagination
    set_up_filters
    set_order

    @projects = @base.paginate(:page => params[:page], :per_page => @per_page)
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
    @project.update_attributes(project_params)
    respond_with(@project) do |format|
      format.html {@project.errors.empty? ? redirect_to(dashboard_path, :notice => "#{@project} project was updated successfully.") : render(:edit)}
    end
  end

  def create
    @project = SpProject.create(project_params.merge({:year => SpApplication.year}))
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
        redirect_to admin_projects_path, :notice => "#{@project} project was deleted."
      end
    end
  end

  def show
    params[:order] = 'name' and params[:direction] = 'ascend' unless params[:order] && params[:direction]
    applications = @project.sp_applications.includes({:person => :current_address})
    staffs = @project.sp_staff

    @accepted_participants = applications.accepted_participants.for_year(@year)
    @accepted_participants = @accepted_participants.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
    @accepted_student_staff = applications.accepted_student_staff.for_year(@year)
    @accepted_student_staff = @accepted_student_staff.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
    @ready_to_evaluate = applications.ready_to_evaluate.for_year(@year)
    @ready_to_evaluate = @ready_to_evaluate.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
    @other = Array.new
    staffs.other_involved.year(@year).each do |staff|
      @other << staff if !staff.person.isStaff?
    end
    @submitted = applications.submitted.for_year(@year)
    @submitted = @submitted.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
    @not_submitted = applications.not_submitted.for_year(@year)
    @not_submitted = @not_submitted.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
    @not_going = applications.not_going.for_year(@year)
    @not_going = @not_going.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
  end

  def download
    year = get_year

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
    applications = SpApplication.find(:all, :conditions => ["status IN ('accepted_as_student_staff', 'accepted_as_participant') and project_id = ? and year = ?", @project.id, year], :include => :person )

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
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = "attachment; filename=\"#{@project.name} - Roster - #{year}.xls\""
    headers['Cache-Control'] = ''
    send_data(sio.string, :type =>  "application/vnd.ms-excel", :filename => "#{@project.name} - Roster - #{year}.xls")
  end

  def dashboard
    redirect_to dashboard_path # defined in application_controller
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
    @group_options = [
      ['',''],
      ['Staff/S. Staff + Accepted Students (Team)','team'],
      ['All Applicants (except withdrawn/denied)','all_applicants'],
      ['All Accepted Students','all_accepted'],
      ['Accepted Men','accepted_men'],
      ['Accepted Women','accepted_women'],
      ['All Staff and S. Staff','staff_and_interns'],
      ['Men Staff and S. Staff','men_staff_and_interns'],
      ['Submitted Applicants','all_submitted'],
      ['Started Applicants','all_started'],
      ['Women Staff and S. Staff','women_staff_and_interns']
    ]
    @group_options << ['Parent References','parent_refs'] if @project.primary_partner == 'MK2MK'
    build_email_hash
  end

  def send_email
    if params[:from].blank?
      flash[:notice] = 'You must specify a "From" address'
      redirect_to :back
    else
      to = params[:to].split(/,|;/)
      recipients = Array.new
      invalid_emails = Array.new
      to.each do |t|
        email = get_email(t.strip)
        if email =~ /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
          recipients << email
        else
          invalid_emails << email
        end
      end

      files = (params[:file] || {}).values
      recipients << params[:from]
      email_success = Array.new
      email_failed = Array.new

      if to.size > 0
        if recipients.count > 0
          recipients.each do |recipient|
            begin
              ProjectMailer.team_email(recipient, params[:from], '', files.compact, params[:subject], params[:body]).deliver
              email_success << recipient
            rescue => e
              raise e.inspect
              email_failed << recipient
            end
          end
          if recipients.size == email_success.size
            notice = "Your email has been sent"
            if invalid_emails.count > 0
              notice += " except to the following invalid email address#{'es' if invalid_emails.count > 1}: "
              invalid_emails_notice = invalid_emails.join(", ")
              notice += invalid_emails_notice
            end
          else
            notice = "Your email has been sent except to the following invalid email address#{'es' if email_failed.size > 1}: "
            if invalid_emails.count > 0
              invalid_emails.each do |invemail|
                email_failed << invemail
              end
            end
            invalid_emails_notice = email_failed.join(", ")
            notice += invalid_emails_notice
          end
          Rails.logger.info ">>>>>>>> #{notice}"
        end
        redirect_to admin_project_path(@project), :notice => notice
      else
        flash[:notice] = 'You must specify a "To" address'
        redirect_to :back
      end
    end
  end

  def sos
    if request.post?
      # find all projects with starting dates in the given range
      projects = SpProject.open.has_chart_field.where(["start_date between ? and ?", params[:start], params[:end]]).includes({:sp_staff => :person}).order('name')
      out = ""
      CSV.generate(out, {:col_sep => "\t", :row_sep => "\n"}) do |writer|
        projects.each do |project|
          contact = project.contact || Person.new
          row_start = [
            project.id,
            project.name,
            project.city,
            project.state,
            Country.where(country: project.country).first.try(:code)
          ]
          row_more = [
            contact.full_name,
            contact.sp_staff.most_recent.first.try(:type).to_s[0..14],
            contact.phone,
            contact.email,
            project.operating_business_unit,
            project.operating_operating_unit,
            project.operating_department,
            project.operating_project
          ]

          date_start = project.international? == "Yes" ? l((project.date_of_departure || project.start_date), :format => :ps) : nil
          date_end = project.international? == "Yes" ? l((project.date_of_return || project.end_date), :format => :ps) : nil

          project.sp_staff.year(SpApplication.year).where("type NOT IN ('Evaluator', 'Coordinator')").each do |staff|
            row = []
            p = staff.person
            # Getting Dates
            unless project.international? == "Yes"
              if staff.type == "PD"
                date_start = l((project.pd_start_date || (project.staff_start_date || project.start_date)), :format => :ps)
                date_end = l((project.pd_end_date || (project.staff_end_date || project.end_date)), :format => :ps)
              else
                date_start = l((project.staff_start_date || project.start_date), :format => :ps)
                date_end = l((project.staff_end_date || project.end_date), :format => :ps)
              end
            end
            if p
              (row_start + [date_start, date_end] + row_more + [p.personID, p.accountNo, p.lastName, p.firstName, staff.type]).each do |val|
                row << (val.present? ? val.to_s.gsub(/[\t\r\n]/, " ") : nil)
              end
              writer << row
              # Store Another Record for Closing
              if project.pd_close_start_date.present? && staff.type == "PD"
                row = []
                date_start = l((project.pd_close_start_date || project.staff_start_date || project.start_date), :format => :ps)
                date_end = l((project.pd_close_end_date || project.staff_end_date || project.end_date), :format => :ps)
                (row_start + [date_start, date_end] + row_more + [p.personID, p.accountNo, p.lastName, p.firstName, staff.type]).each do |val|
                  row << (val.present? ? val.to_s.gsub(/[\t\r\n]/, " ") : nil)
                end
                writer << row
              end
            end
          end
          project.sp_applications.for_year(SpApplication.year).accepted.includes(:person).each do |applicant|
            row = []
            p = applicant.person
            if p
              # Getting Dates
              unless project.international? == "Yes"
                if applicant.status == 'accepted_as_student_staff'
                  date_start = l((project.student_staff_start_date || project.start_date), :format => :ps)
                  date_end = l((project.student_staff_end_date || project.end_date), :format => :ps)
                else
                  date_start = l(project.start_date, :format => :ps)
                  date_end = l(project.end_date, :format => :ps)
                end
              end
              (row_start + [date_start, date_end] + row_more + [p.personID, p.accountNo, p.lastName, p.firstName, 'Applicant']).each do |val|
                row << (val.present? ? val.to_s.gsub(/[\t\r\n]/, " ") : nil)
              end
            end
            writer << row
          end
        end
      end
      send_data(out, :filename => "sos.txt", :type => 'text/tab' )
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
    @base = params[:closed] ? SpProject : SpProject.open
    @filter_title = 'All'
    selected_filters = params[:partners]

    if selected_filters.present?
      report_stats_to_query = Array.new
      if selected_filters.include?("US Campus")
        selected_filters = selected_filters.select{|x| x != "US Campus"}
        report_stats_to_query << "report_stats_to = 'Campus Ministry - US summer project'"
      end

      if selected_filters.include?("Non-USCM SPs")
        selected_filters = selected_filters.select{|x| x != "Non-USCM SPs"}
        report_stats_to_query << "report_stats_to = 'Other Cru ministry'"
      end

      if report_stats_to_query.present?
        @base = @base.where(report_stats_to_query.join(' OR '))
      end

      if selected_filters.present?
        @base = @base.where("primary_partner IN(?) OR secondary_partner IN(?) OR tertiary_partner IN(?)", selected_filters, selected_filters, selected_filters)
      end

      @filter_title = params[:partners].sort.join(', ')
    end
    case
    when params[:search].present?
      @base = @base.where("name like ?", "%#{params[:search]}%")
    when params[:search_pd].present?
      @base = @base.includes(:sp_staff => :person).pd_like(params[:search_pd])
    when params[:search_apd].present?
      @base = @base.includes(:sp_staff => :person).apd_like(params[:search_apd])
    when params[:search_opd].present?
      @base = @base.includes(:sp_staff => :person).opd_like(params[:search_opd])
    end

    # Filter based on the user type
    case sp_user.class.to_s
    when 'SpDirector', 'SpProjectStaff', 'SpEvaluator'
      @base = @base.where(:id => current_person.current_staffed_projects.collect(&:id))
    when 'SpRegionalCoordinator'
      @base = @base.where("primary_partner IN(?) OR secondary_partner IN(?) OR tertiary_partner IN(?)", sp_user.partnerships, sp_user.partnerships, sp_user.partnerships) if sp_user.partnerships.present?
    when 'SpNationalCoordinator', 'SpDonationServices'
    else
      @base = @base.where('1 <> 1')
    end
  end

  def set_order
    params[:order] = 'name' and params[:direction] = 'ascend' unless params[:order] && params[:direction]
    @base = @base.send("#{params[:direction]}_by_#{params[:order]}".downcase.to_sym)
  end

  def get_countries
    @countries = Country.order(:country)
  end

  def get_year
    @year = params[:year] || @project.try(:year) || SpApplication.year
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
      when 'all_submitted'
        applicant_conditions = "status IN ('submitted')"
        include_applicants = true
      when 'all_started'
        applicant_conditions = "status IN ('started')"
        include_applicants = true
      when 'all_applicants'
        applicant_conditions = "status NOT IN ('declined', 'withdrawn')"
        include_applicants = true
      when 'all_accepted'
        applicant_conditions = "status IN ('accepted_as_student_staff', 'accepted_as_participant')"
        include_applicants = true
      when 'accepted_men'
        applicant_conditions = "status IN ('accepted_as_student_staff', 'accepted_as_participant') AND ministry_person.gender = 1"
        include_applicants = true
      when 'accepted_women'
        applicant_conditions = "status IN ('accepted_as_student_staff', 'accepted_as_participant') AND ministry_person.gender = 0"
        include_applicants = true
      when 'staff_and_interns'
        applicant_conditions = "status IN ('accepted_as_student_staff')"
        include_applicants = true
        include_staff = true
      when 'men_staff_and_interns'
        applicant_conditions = "status IN ('accepted_as_student_staff') AND ministry_person.gender = 1"
        include_applicants = true
        include_staff = true
      when 'women_staff_and_interns'
        applicant_conditions = "status IN ('accepted_as_student_staff') AND ministry_person.gender = 0"
        include_applicants = true
        include_staff = true
      when 'parent_refs'
        include_applicants = false
        include_staff = false
        parent_refs = true
      else
        applicant_conditions = "status IN ('accepted_as_student_staff', 'accepted_as_participant')"
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
        addresses = ReferenceSheet.where('sp_applications.project_id' => @project.id, 'sp_elements.style' => 'parent').includes(:applicant_answer_sheet, :question).collect(&:email)
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

  def get_email(str)
    if str.index("<")
      first = str.index("<") + 1
      last = str.index(">") ? str.index(">") - 1 : str.size - 1
      str[first..last]
    else
      str
    end
  end

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

  def project_params
    params.fetch(:sp_project).permit(:name, :show_on_website, :job, :display_location, :secure, :city, :state, :country, :world_region, :start_date, :end_date, :primary_ministry_focus_id, :ministry_focus_ids, :url, :url_title, :facebook_url, :blog_url, :blog_title, :student_cost, :max_accepted_men, :max_accepted_women, :description, :student_quotes_attributes, :use_provided_application, :partner_region_only, :apply_by_date, :basic_info_question_sheet_id, :template_question_sheet_id, :project_contact_name, :project_contact_role, :project_contact_phone, :project_contact_email, :project_contact2_name, :project_contact2_role, :project_contact2_phone, :project_contact2_email, :pd_start_date, :pd_end_date, :pd_close_start_date, :pd_close_end_date, :staff_start_date, :staff_end_date, :student_staff_start_date, :student_staff_end_date, :open_application_date, :archive_project_date, :date_of_departure, :date_of_return, :medical_clinic, :medical_clinic_location, :departure_city, :destination_city, :in_country_contact, :primary_partner, :secondary_partner, :tertiary_partner, :report_stats_to, :staff_cost, :intern_cost, :high_school, :background_checks_required, :operating_business_unit, :operating_operating_unit, :operating_department, :operating_project, :operating_designation, :scholarship_business_unit, :scholarship_operating_unit, :scholarship_department, :scholarship_project, :scholarship_designation)
  end

end
