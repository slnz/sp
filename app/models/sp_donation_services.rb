class SpDonationServices < SpUser
  def can_upload_ds?
    true
  end

  def can_search?
    true
  end

  def can_see_dashboard?
    true
  end

  def scope(partner = nil)
    if partner
      @scope ||= ['primary_partner ilike ? OR secondary_partner ilike ? OR tertiary_partner ilike ?', partner, partner, partner]
    else
      @scope ||= ['1=1'] # all projects
    end
  end

  def role
    'Donation Services'
  end

  def self.generate_file(current_person)
    t = "\t"
    endl = "\n"
    out = ''
    results = []
    CSV.generate(out, col_sep: t, row_sep: endl) do |writer|
      selects = "
        SELECT
          person.id,
          person.first_name,
          person.last_name,
          person.gender,
          person.title,
          person.account_no,
          person.donor_number,
          spouse.id AS spouse_id,
          spouse.first_name AS spouse_first_name,
          spouse.last_name AS spouse_last_name,
          spouse.title AS spouse_title,
          spouse.gender AS spouse_gender,
          currentAddress.address1 AS current_address,
          currentAddress.city AS current_city,
          currentAddress.state AS current_state,
          currentAddress.zip AS current_zip,
          currentAddress.home_phone AS current_telephone,
          currentAddress.email AS current_email,
          permanentAddress.address1 AS permanent_address,
          project.name AS project_name,
          project.scholarship_designation,
          project.scholarship_business_unit,
          project.scholarship_operating_unit,
          project.scholarship_department,
          project.scholarship_project,
          project.ds_project_code"

      # Student applications (including Student Staff)
      rows = ActiveRecord::Base.connection.select_all("
                                                      #{selects}
        FROM ministry_person person
        JOIN sp_applications app
          ON (app.person_id = person.id)
        JOIN sp_projects project
          ON (app.project_id = project.id)
        LEFT JOIN ministry_newaddress currentAddress
          ON (currentAddress.address_type = 'current'
            AND currentAddress.person_id = person.id)
        LEFT JOIN ministry_newaddress permanentAddress
          ON (permanentAddress.address_type = 'permanent'
            AND permanentAddress.person_id = person.id)
        LEFT JOIN ministry_person spouse
          ON (person.\"fk_spouseID\" = spouse.id)
        LEFT JOIN sp_designation_numbers designation
          ON (person.id = designation.person_id
            AND project.id = designation.project_id)
            AND designation.year = app.year
        WHERE app.status IN ('accepted_as_student_staff','accepted_as_participant')
          AND app.year >= '#{SpApplication.year}'
          AND (person.\"isStaff\" IS FALSE OR person.\"isStaff\" IS NULL)
          AND (designation.designation_number IS NULL or designation.designation_number = '')
          AND project.scholarship_designation > '0000000'
          AND project.scholarship_designation < '3000000'
          AND project.scholarship_operating_unit IS NOT NULL
          AND project.scholarship_operating_unit != ''
        ORDER BY
          person.last_name,
          person.first_name;").to_a

      # People from "Other" tab (primarily non-staff that are in sp_staff table)
      rows2 = ActiveRecord::Base.connection.select_all("
                                                       #{selects}
        FROM ministry_person person
        JOIN sp_staff staff
          ON (person.id = staff.person_id)
        JOIN sp_projects project
          ON (staff.project_id = project.id)
        LEFT JOIN ministry_newaddress currentAddress
          ON (currentAddress.address_type = 'current'
            AND currentAddress.person_id = person.id)
        LEFT JOIN ministry_newaddress permanentAddress
          ON (permanentAddress.address_type = 'permanent'
            AND permanentAddress.person_id = person.id)
        LEFT JOIN ministry_person spouse
          ON (person.\"fk_spouseID\" = spouse.id)
        LEFT JOIN sp_designation_numbers designation
          ON (person.id = designation.person_id
            AND project.id = designation.project_id)
            AND designation.year = staff.year
        WHERE staff.type NOT IN ('Kid','Evaluator','Coordinator','Staff')
          AND staff.year = '#{SpApplication.year}'
          AND (person.\"isStaff\" IS FALSE OR person.\"isStaff\" IS NULL)
          AND (designation.designation_number IS NULL or designation.designation_number = '')
          AND project.scholarship_designation > '0000000'
          AND project.scholarship_designation < '3000000'
          AND project.scholarship_operating_unit IS NOT NULL
          AND project.scholarship_operating_unit != ''
        ORDER BY
          person.last_name,
          person.first_name;")

      column_headers = %w(OPER_NAME KEYED_DATE PEOPLE_ID DONOR_ID STATUS ORG_ID PERSON_TYPE TITLE FIRST_NAME MIDDLE_NAME LAST_NAME_ORG SUFFIX SPOUSE_TITLE SPOUSE_FIRST SPOUSE_MIDDLE SPOUSE_LAST SPOUSE_SUFFIX ADDRESS1 ADDRESS2 ADDRESS3 CITY STATE ZIP TELEPHONE TELE_TYPE COUNTRY INTL_ZIP ADDR_TYPE ADDR_START ADDR_STOP ADDR_NAME SALUTATION EMAIL EMAIL_TYPE PRIM_EMAIL SVC_IND_MAIL SVC_IND_TELE SOURCE_MOTIV SOURCE_DATE MIN_MAIL_IND MIN_TELE_IND MIN_SVC_CODE MIN_SVC_TYPE MIN_SVC_DATE MIN_SVC_DESC AMT_PAID LIST_ID WSN_APPLICATION_ID ASSIGNMENT_NAME SCHOLARSHIP_BUSINESS_UNIT SCHOLARSHIP_OPERATING_UNIT SCHOLARSHIP_DEPT_ID SCHOLARSHIP_PROJECT_ID SCHOLARSHIP_DESIGNATION PROJECT_CODE)

      writer << column_headers

      today = Time.now.strftime('%Y%m%d')

      rows.each do |row2|
        results << row2
      end

      rows2.each do |row2|
        results << row2
      end

      results.each do |row|
        values = Hash.new

        values['OPER_NAME'] = current_person.to_s

        values['KEYED_DATE'] = today
        values['PEOPLE_ID'] = row['account_no']
        values['DONOR_ID'] = row['donor_number']
        values['STATUS'] = ''
        values['ORG_ID'] = 'CAMPUS'
        values['PERSON_TYPE'] = 'P'
        values['TITLE'] = get_title(row['gender'], row['title'])
        values['FIRST_NAME'] = row['first_name']
        values['LAST_NAME_ORG'] = row['last_name']
        values['SUFFIX'] = ''
        values['SPOUSE_TITLE'] = row['spouse_id'].nil? ? '' : get_title(row['spouse_gender'], row['spouse_title'])
        values['SPOUSE_FIRST'] = row['spouse_first_name']
        values['SPOUSE_MIDDLE'] = ''
        values['SPOUSE_LAST'] = row['spouse_last_name']
        values['SPOUSE_SUFFIX'] = ''
        values['ADDRESS1'] = row['current_address']
        values['ADDRESS2'] = ''
        values['ADDRESS3'] = ''
        values['CITY'] = row['current_city']
        values['STATE'] = row['current_state']
        values['ZIP'] = row['current_zip']
        values['TELEPHONE'] = ''
        values['TELE_TYPE'] = ''
        values['COUNTRY'] = 'USA'
        values['INTL_ZIP'] = ''
        values['ADDR_TYPE'] = 'PRIM'
        values['ADDR_START'] = today
        values['ADDR_STOP'] = ''
        values['ADDR_NAME'] = ''
        values['SALUTATION'] = ''
        values['EMAIL'] = row['current_email']
        values['EMAIL_TYPE'] = 'HM'
        values['PRIM_EMAIL'] = 'Y'
        values['SVC_IND_MAIL'] = '0'
        values['SVC_IND_TELE'] = '0'
        values['SOURCE_MOTIV'] = 'USLOAD'
        values['SOURCE_DATE'] = today
        values['MIN_MAIL_IND'] = ''
        values['MIN_TELE_IND'] = ''
        values['MIN_SVC_CODE'] = ''
        values['MIN_SVC_TYPE'] = ''
        values['MIN_SVC_DATE'] = ''
        values['MIN_SVC_DESC'] = ''
        values['AMT_PAID'] = ''
        values['LIST_ID'] = ''
        values['WSN_APPLICATION_ID'] = row['id']
        values['ASSIGNMENT_NAME'] = row['project_name']
        values['SCHOLARSHIP_BUSINESS_UNIT'] = row['scholarship_business_unit'].to_s.upcase
        values['SCHOLARSHIP_OPERATING_UNIT'] = row['scholarship_operating_unit'].to_s.upcase
        values['SCHOLARSHIP_DEPT_ID'] = row['scholarship_department'].to_s.upcase
        values['SCHOLARSHIP_PROJECT_ID'] = row['scholarship_project'].to_s.upcase
        values['SCHOLARSHIP_DESIGNATION'] = row['scholarship_designation']
        values['PROJECT_CODE'] = row['ds_project_code']

        row = []
        column_headers.each do |header|
          if values[header] && values[header] != ''
            row << values[header].to_s.gsub(/[\t\r\n]/, '').gsub(/,/, ' ')
          else
            row << nil
          end
        end
        writer << row
      end
    end
  end

  # peoplesoft codes for titles
  def self.get_title(gender, title)
    if title.nil? || title == ''
      if (gender == '0')
        return '11'
      else
        return '01'
      end
    else
      case title
        when 'Mr.'
          return '01'
        when 'Ms.'
          return '11'
        when 'Mrs.'
          return '03'
        else
          return '01'
      end
    end
  end
end
