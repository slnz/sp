require 'csv'
class Admin::DonationServicesController < ApplicationController
  before_filter CASClient::Frameworks::Rails3::Filter, AuthenticationFilter
  before_filter :check_has_permission

  layout 'admin'

  def index
  end

  def download

    headers['Content-Type'] = "text/tab"
    headers['Content-Disposition'] = 'attachment; filename="sp_need_account_no.txt"'
    headers['Cache-Control'] = ''


    t = "\t"
    endl = "\n"
    out = ""
    CSV.generate(out, {:col_sep => t, :row_sep => endl}) do |writer|
   
#     rows = ActiveRecord::Base.connection.select_all("select app.id as appId, person.firstName, person.lastName, person.gender, person.title, person.accountNo,
#                                                person.donor_number, spouse.personID as spouseID, spouse.firstName as spouseFirstName,
#                                                spouse.lastName as spouseLastName, spouse.title as spouseTitle, spouse.gender as spouseGender,
#                                                person.accountNo, currentAddress.address1 as currentAddress, currentAddress.city as currentCity, 
#                                                currentAddress.state as currentState, currentAddress.zip as currentZip, currentAddress.homePhone as currentTelephone,
#                                                currentAddress.email as currentEmail, permanentAddress.address1 as permanentAddress, project.name as projectName,
#                                                project.scholarship_designation, project.scholarship_business_unit, project.scholarship_operating_unit,
#                                                project.scholarship_department, project.scholarship_project, project.ds_project_code from ministry_person person 
#                                                join sp_applications app on (app.person_id = person.personID) join sp_projects project on (app.project_id = project.id)
#                                                left join ministry_newaddress currentAddress on (currentAddress.addressType = 'current' and
#                                                currentAddress.fk_personId = person.personID) left join ministry_newaddress permanentAddress on
#                                                (permanentAddress.addressType = 'permanent' and permanentAddress.fk_personId = person.personID) 
#                                                left join ministry_person spouse on (person.fk_spouseID = spouse.personID) where app.year = '#{SpApplication::YEAR}'
#                                                and app.status IN ('accepted_as_student_staff','accepted_as_participant') and app.designation_number is null and 
#                                                project.scholarship_designation > '1000000' and project.scholarship_designation < '3000000' and
#                                                project.scholarship_operating_unit is not null and project.scholarship_operating_unit != '' order
#                                                by person.lastName, person.firstName;");
          
      selects = "
        SELECT 
          person.personID, 
          person.firstName, 
          person.lastName, 
          person.gender, 
          person.title, 
          person.accountNo,
          person.donor_number, 
          spouse.personID AS spouseID, 
          spouse.firstName AS spouseFirstName,
          spouse.lastName AS spouseLastName,
          spouse.title AS spouseTitle,
          spouse.gender AS spouseGender,
          person.accountNo, 
          currentAddress.address1 AS currentAddress,
          currentAddress.city AS currentCity, 
          currentAddress.state AS currentState,
          currentAddress.zip AS currentZip,
          currentAddress.homePhone AS currentTelephone,
          currentAddress.email AS currentEmail,
          permanentAddress.address1 AS permanentAddress,
          project.name AS projectName,
          project.scholarship_designation,
          project.scholarship_business_unit,
          project.scholarship_operating_unit,
          project.scholarship_department,
          project.scholarship_project,
          project.ds_project_code"
          
      rows = ActiveRecord::Base.connection.select_all("
        #{selects}
        FROM ministry_person person 
        JOIN sp_applications app 
          ON (app.person_id = person.personID) 
        JOIN sp_projects project
          ON (app.project_id = project.id)
        LEFT JOIN ministry_newaddress currentAddress
          ON (currentAddress.addressType = 'current'
            AND currentAddress.fk_personId = person.personID)
        LEFT JOIN ministry_newaddress permanentAddress
          ON (permanentAddress.addressType = 'permanent'
            AND permanentAddress.fk_personId = person.personID) 
        LEFT JOIN ministry_person spouse
          ON (person.fk_spouseID = spouse.personID)
        LEFT JOIN sp_designation_numbers designation
          ON (person.personID = designation.person_id
            AND project.id = designation.project_id)
        WHERE app.status IN ('accepted_as_student_staff','accepted_as_participant')
          AND app.year = '#{SpApplication::YEAR}'
          AND (person.isStaff = 0 OR person.isStaff IS NULL)
          AND (designation.designation_number IS NULL or designation.designation_number = '')
          AND project.scholarship_designation > '1000000'
          AND project.scholarship_designation < '3000000'
          AND project.scholarship_operating_unit IS NOT NULL
          AND project.scholarship_operating_unit != '' 
        ORDER BY
          person.lastName,
          person.firstName;");
          
      rows2 = ActiveRecord::Base.connection.select_all("
        #{selects}
        FROM ministry_person person 
        JOIN sp_staff staff
          ON (person.personID = staff.person_id)
        JOIN sp_projects project
          ON (staff.project_id = project.id)
        LEFT JOIN ministry_newaddress currentAddress
          ON (currentAddress.addressType = 'current'
            AND currentAddress.fk_personId = person.personID)
        LEFT JOIN ministry_newaddress permanentAddress
          ON (permanentAddress.addressType = 'permanent'
            AND permanentAddress.fk_personId = person.personID) 
        LEFT JOIN ministry_person spouse
          ON (person.fk_spouseID = spouse.personID)
        LEFT JOIN sp_designation_numbers designation
          ON (person.personID = designation.person_id
            AND project.id = designation.project_id)
        WHERE staff.type NOT IN ('Kid','Evaluator','Coordinator','Staff')
          AND staff.year = '#{SpApplication::YEAR}'
          AND (person.isStaff = 0 OR person.isStaff IS NULL)
          AND (designation.designation_number IS NULL or designation.designation_number = '')
          AND project.scholarship_designation > '1000000'
          AND project.scholarship_designation < '3000000'
          AND project.scholarship_operating_unit IS NOT NULL
          AND project.scholarship_operating_unit != '' 
        ORDER BY
          person.lastName,
          person.firstName;");

      column_headers = ["OPER_NAME", "KEYED_DATE", "PEOPLE_ID", "DONOR_ID", "STATUS", "ORG_ID",
  			"PERSON_TYPE", "TITLE", "FIRST_NAME", "MIDDLE_NAME", "LAST_NAME_ORG", "SUFFIX",
  			"SPOUSE_TITLE", "SPOUSE_FIRST", "SPOUSE_MIDDLE", "SPOUSE_LAST", "SPOUSE_SUFFIX",
  			"ADDRESS1", "ADDRESS2", "ADDRESS3", "CITY", "STATE", "ZIP", "TELEPHONE", "TELE_TYPE",
  			"COUNTRY", "INTL_ZIP", "ADDR_TYPE", "ADDR_START", "ADDR_STOP", "ADDR_NAME", "SALUTATION",
  			"EMAIL", "EMAIL_TYPE", "PRIM_EMAIL", "SVC_IND_MAIL", "SVC_IND_TELE", "SOURCE_MOTIV",
  			"SOURCE_DATE", "MIN_MAIL_IND", "MIN_TELE_IND", "MIN_SVC_CODE", "MIN_SVC_TYPE",
  			"MIN_SVC_DATE", "MIN_SVC_DESC", "AMT_PAID", "LIST_ID", "WSN_APPLICATION_ID", "ASSIGNMENT_NAME",
  			"SCHOLARSHIP_BUSINESS_UNIT", "SCHOLARSHIP_OPERATING_UNIT",
  			"SCHOLARSHIP_DEPT_ID", "SCHOLARSHIP_PROJECT_ID", "SCHOLARSHIP_DESIGNATION", "PROJECT_CODE"];

      writer << column_headers

      today = Time.now.strftime('%Y%m%d')
      
      rows2.each do |row2|
        rows << row2
      end
      rows.each do |row|
        values = Hash.new

        values["OPER_NAME"] = current_person.to_s

        values["KEYED_DATE"] = today
        values["PEOPLE_ID"] = row["accountNo"]
        values["DONOR_ID"] = row["donor_number"]
        values["STATUS"] = ""
        values["ORG_ID"] = "CAMPUS"
        values["PERSON_TYPE"] = "P"
        values["TITLE"] = get_title(row["gender"], row["title"])
        values["FIRST_NAME"] = row["firstName"]
        values["LAST_NAME_ORG"] = row["lastName"]
        values["SUFFIX"] = ""
        values["SPOUSE_TITLE"] = row["spouseID"].nil? ? "" : get_title(row["spouseGender"], row["spouseTitle"])
        values["SPOUSE_FIRST"] = row["spouseFirstName"]
        values["SPOUSE_MIDDLE"] = ""
        values["SPOUSE_LAST"] = row["spouseLastName"]
        values["SPOUSE_SUFFIX"] = ""
        values["ADDRESS1"] = row["currentAddress"]
        values["ADDRESS2"] = ""
        values["ADDRESS3"] = ""
        values["CITY"] = row["currentCity"]
        values["STATE"] = row["currentState"]
        values["ZIP"] = row["currentZip"]
        values["TELEPHONE"] = ""
        values["TELE_TYPE"] = ""
        values["COUNTRY"] = "USA"
        values["INTL_ZIP"] = ""
        values["ADDR_TYPE"] = "PRIM"
        values["ADDR_START"] = today
        values["ADDR_STOP"] = ""
        values["ADDR_NAME"] = ""
        values["SALUTATION"] = ""
        values["EMAIL"] = row["currentEmail"]
        values["EMAIL_TYPE"] = "HM"
        values["PRIM_EMAIL"] = "Y"
        values["SVC_IND_MAIL"] = "0"
        values["SVC_IND_TELE"] = "0"
        values["SOURCE_MOTIV"] = "USLOAD"
        values["SOURCE_DATE"] = today
        values["MIN_MAIL_IND"] = ""
        values["MIN_TELE_IND"] = ""
        values["MIN_SVC_CODE"] = ""
        values["MIN_SVC_TYPE"] = ""
        values["MIN_SVC_DATE"] = ""
        values["MIN_SVC_DESC"] = ""
        values["AMT_PAID"] = ""
        values["LIST_ID"] = ""
        values["WSN_APPLICATION_ID"] = row["personID"]
        values["ASSIGNMENT_NAME"] = row["projectName"]
        values["SCHOLARSHIP_BUSINESS_UNIT"] = row["scholarship_business_unit"].upcase
        values["SCHOLARSHIP_OPERATING_UNIT"] = row["scholarship_operating_unit"].upcase
        values["SCHOLARSHIP_DEPT_ID"] = row["scholarship_department"].upcase
        values["SCHOLARSHIP_PROJECT_ID"] = row["scholarship_project"].upcase
        values["SCHOLARSHIP_DESIGNATION"] = row["scholarship_designation"]
        values["PROJECT_CODE"] = row["ds_project_code"]


        row = []
        column_headers.each do |header|
          if (values[header] && values[header] != "")
            row << values[header].to_s.gsub(/[\t\r\n]/, "").gsub(/,/, " ")
          else
            row << nil
          end
        end
        writer << row
      end
    end

    send_data(out, :filename => "sp_need_account_no.txt", :type => 'text/tab' )
  end

  def upload
    @error_messages = Array.new
    unless params[:upload].present? && params[:upload][:upload].present?
      @error_messages << "Please upload a .csv file"
      return
    end
    upload = params[:upload][:upload]
      
    begin
      @filename = upload.original_filename
    rescue NoMethodError
      @error_messages << "Invalid upload"
      return
    end
    # unless File.extname(@filename) == '.csv'
    #   @error_messages = "Please upload a .csv file. The file you uploaded was #{File.extname(@filename)}"
    #   return
    # end
    begin
      @warning_messages = Array.new
      designation_numbers_to_update = Hash.new
      persons_to_update = Hash.new
      row_num = 0
      Excelsior::Reader.rows(upload) do |row|
        row_num += 1
        if row.length < 3
          @error_messages << "Row #{row_num} is invalid: too short"
        else
          person_id = row[2]
          donor_number = row[1]
          designation_number = row[0]
          unless person_id.present? && designation_number.present? && designation_number != 0 && donor_number.present?
            @error_messages << "Row #{row_num} is invalid: missing required data"
          else
            application = nil
            begin
              designation_numbers_to_update[person_id] = designation_number.to_i
              persons_to_update[person_id] = donor_number
            rescue ActiveRecord::RecordNotFound
              @error_messages << "Person #{person_id} or subsequent does not exist"
            end
          end
        end
      end
      @error_messages << "File contains no rows" if row_num == 0
    # rescue CSV::IllegalFormatError
      # @error_messages << "csv file is invalid"
    end
    if !@error_messages.empty?
      return
    end

    @num_emails_sent = 0
    designation_numbers_to_update.each do |person_id, designation_number|
      person = Person.find(person_id)
      donor_number = persons_to_update[person_id]
      
      record = SpApplication.where(:person_id => person_id, :year => SpApplication::YEAR).first
      record ||= SpStaff.where(:person_id => person_id, :year => SpApplication::YEAR).first
      
      if record.present?
        project_id = record.project_id
        unless project_id.present?
          @warning_messages << "Person #{person_id} is not assigned to a project; skipping"
        else
          # if (application.designation_number == designation_number && person.donor_number == donor_number)
          if record.designation_number == designation_number && person.donor_number == donor_number
            @warning_messages << "Person #{person_id} has already been assigned " + 
              "this designation number (#{designation_number}) " +
              "and has already been assigned this donor id (#{donor_number}); no update necessary"
          else
            if record.designation_number.present? && record.designation_number != designation_number
              @warning_messages << "Person #{person_id} was previously assigned a different " + 
                "designation number (#{record.designation_number}); reassigning to #{designation_number}"
            end
            if !person.donor_number.blank? && person.donor_number != donor_number
              @warning_messages << "Person #{person_id} was previously assigned a different donor id (#{person.donor_number}); reassigning to #{donor_number}"
            end
            
            # Update Records
            record.designation_number = designation_number
            person.donor_number = donor_number
            
            if !record.valid?
              @warning_messages << "Person #{person_id} or subsequent record is corrupted and cannot be updated; " +
               "please contact help@campuscrusadeforchrist.com"
            else
              project = SpProject.find(project_id)
              leaders = Hash.new
              leaders["Project Director"] = project.pd
              leaders["Operations Project Director"] = project.opd
              leaders["Coordinator"] = project.coordinator
              recipients = Array.new
              leaders.each do |position, leader|
                if leader
                  if !(leader.current_address && !leader.current_address.email.blank?)
                    @warning_messages << "#{position} for project #{project.id} does not have an email address"
                  else
                    recipients << leader.current_address.email
                  end
                end
              end
              if recipients.empty?
                record.save!
                person.save!
                @warning_messages << "No leaders have been notified of person #{person_id}'s designation number assignment"
              else
                Notifier.notification(recipients, # RECIPIENTS
                                      "gosummerproject@uscm.org", # FROM
                                      "Designation Number Assigned", # LIQUID TEMPLATE NAME
                                      {'name' => person.try(:informal_full_name),
                                       'project_name' => project.name,
                                       'email' => person && person.current_address ? person.current_address.email : nil,
                                       'designation_number' => designation_number,
                                       'donor_number' => donor_number}).deliver
                @num_emails_sent += 1
                record.save!
                person.save!
              end
            end
          end
        end
      else
        @warning_messages << "Person #{person_id} is not assigned to a project; skipping"
      end
    end
  end

  protected

  #peoplesoft codes for titles
  def get_title(gender, title)
    if (title.nil? || title == "")
      if (gender == "0")
        return "11"
      else
        return "01"
      end
    else
      case title
      when "Mr."
        return "01"
      when "Ms."
        return "11"
      when "Mrs."
        return "03"
      else
        return "01"
      end
    end
  end

  def check_has_permission
    unless sp_user.can_upload_ds?
      flash[:error] = "You don't have permission to upload account numbers."
      redirect_to(request.referrer ? :back : '/admin')
      return false
    end
  end
end
