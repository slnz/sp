# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100909163315) do

  create_table "aoas", :force => true do |t|
    t.string "name"
  end

  create_table "counties", :force => true do |t|
    t.string "name"
    t.string "state"
  end

  add_index "counties", ["state"], :name => "state"

  create_table "countries", :force => true do |t|
    t.string  "country",  :limit => 100
    t.string  "code",     :limit => 10
    t.boolean "closed",                  :default => false
    t.string  "iso_code"
  end

  create_table "ministries", :force => true do |t|
    t.string "name"
  end

  create_table "ministry_newaddress", :primary_key => "addressID", :force => true do |t|
    t.string   "deprecated_startDate", :limit => 25
    t.string   "deprecated_endDate",   :limit => 25
    t.string   "address1",             :limit => 55
    t.string   "address2",             :limit => 55
    t.string   "address3",             :limit => 55
    t.string   "address4",             :limit => 55
    t.string   "city",                 :limit => 50
    t.string   "state",                :limit => 50
    t.string   "zip",                  :limit => 15
    t.string   "country",              :limit => 64
    t.string   "homePhone",            :limit => 25
    t.string   "workPhone",            :limit => 25
    t.string   "cellPhone",            :limit => 25
    t.string   "fax",                  :limit => 25
    t.string   "email",                :limit => 200
    t.string   "url",                  :limit => 100
    t.string   "contactName",          :limit => 50
    t.string   "contactRelationship",  :limit => 50
    t.string   "addressType",          :limit => 20
    t.datetime "dateCreated"
    t.datetime "dateChanged"
    t.string   "createdBy",            :limit => 50
    t.string   "changedBy",            :limit => 50
    t.integer  "fk_PersonID"
    t.string   "email2",               :limit => 200
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "facebook_link"
    t.string   "myspace_link"
    t.string   "title"
    t.string   "dorm"
    t.string   "room"
    t.string   "preferredPhone",       :limit => 25
    t.string   "phone1_type",                         :default => "cell"
    t.string   "phone2_type",                         :default => "home"
    t.string   "phone3_type",                         :default => "work"
  end

  add_index "ministry_newaddress", ["addressType", "fk_PersonID"], :name => "unique_person_addressType", :unique => true
  add_index "ministry_newaddress", ["addressType"], :name => "index_ministry_newAddress_on_addressType"
  add_index "ministry_newaddress", ["email"], :name => "email"
  add_index "ministry_newaddress", ["fk_PersonID"], :name => "fk_PersonID"

  create_table "ministry_person", :primary_key => "personID", :force => true do |t|
    t.string   "accountNo",                     :limit => 11
    t.string   "lastName",                      :limit => 50
    t.string   "firstName",                     :limit => 50
    t.string   "middleName",                    :limit => 50
    t.string   "preferredName",                 :limit => 50
    t.string   "gender",                        :limit => 1
    t.string   "region",                        :limit => 5
    t.boolean  "workInUS",                                            :default => true,  :null => false
    t.boolean  "usCitizen",                                           :default => true,  :null => false
    t.string   "citizenship",                   :limit => 50
    t.boolean  "isStaff"
    t.string   "title",                         :limit => 5
    t.string   "campus",                        :limit => 128
    t.string   "universityState",               :limit => 5
    t.string   "yearInSchool",                  :limit => 20
    t.string   "major",                         :limit => 70
    t.string   "minor",                         :limit => 70
    t.string   "greekAffiliation",              :limit => 50
    t.string   "maritalStatus",                 :limit => 20
    t.string   "numberChildren",                :limit => 2
    t.boolean  "isChild",                                             :default => false, :null => false
    t.text     "bio",                           :limit => 2147483647
    t.string   "image",                         :limit => 100
    t.string   "occupation",                    :limit => 50
    t.string   "blogfeed",                      :limit => 200
    t.datetime "cruCommonsInvite"
    t.datetime "cruCommonsLastLogin"
    t.datetime "dateCreated"
    t.datetime "dateChanged"
    t.string   "createdBy",                     :limit => 50
    t.string   "changedBy",                     :limit => 50
    t.integer  "fk_ssmUserId"
    t.integer  "fk_StaffSiteProfileID"
    t.integer  "fk_spouseID"
    t.integer  "fk_childOf"
    t.datetime "birth_date"
    t.datetime "date_became_christian"
    t.datetime "graduation_date"
    t.string   "level_of_school"
    t.string   "staff_notes"
    t.string   "donor_number",                  :limit => 11
    t.string   "url",                           :limit => 2000
    t.string   "isSecure",                      :limit => 1
    t.integer  "primary_campus_involvement_id"
    t.integer  "mentor_id"
    t.string   "lastAttended",                  :limit => 20
    t.string   "ministry"
  end

  add_index "ministry_person", ["accountNo"], :name => "accountNo_ministry_Person"
  add_index "ministry_person", ["campus"], :name => "campus"
  add_index "ministry_person", ["firstName"], :name => "firstname_ministry_Person"
  add_index "ministry_person", ["fk_ssmUserId"], :name => "fk_ssmUserId"
  add_index "ministry_person", ["lastName"], :name => "lastname_ministry_Person"
  add_index "ministry_person", ["region"], :name => "region_ministry_Person"

  create_table "ministry_regionalteam", :primary_key => "teamID", :force => true do |t|
    t.string   "name",      :limit => 100
    t.string   "note"
    t.string   "region",    :limit => 2
    t.string   "address1",  :limit => 35
    t.string   "address2",  :limit => 35
    t.string   "city",      :limit => 30
    t.string   "state",     :limit => 6
    t.string   "zip",       :limit => 10
    t.string   "country",   :limit => 64
    t.string   "phone",     :limit => 24
    t.string   "fax",       :limit => 24
    t.string   "email",     :limit => 50
    t.string   "url"
    t.string   "isActive",  :limit => 1
    t.datetime "startdate"
    t.datetime "stopdate"
    t.string   "no",        :limit => 80
    t.string   "abbrv",     :limit => 80
    t.string   "hrd",       :limit => 50
    t.string   "spPhone",   :limit => 24
  end

  create_table "ministry_staff", :force => true do |t|
    t.string   "accountNo",                :limit => 11,                                                  :null => false
    t.string   "firstName",                :limit => 30
    t.string   "middleInitial",            :limit => 1
    t.string   "lastName",                 :limit => 30
    t.string   "isMale",                   :limit => 1
    t.string   "position",                 :limit => 30
    t.string   "countryStatus",            :limit => 10
    t.string   "jobStatus",                :limit => 60
    t.string   "ministry",                 :limit => 35
    t.string   "strategy",                 :limit => 20
    t.string   "isNewStaff",               :limit => 1
    t.string   "primaryEmpLocState",       :limit => 6
    t.string   "primaryEmpLocCountry",     :limit => 64
    t.string   "primaryEmpLocCity",        :limit => 35
    t.string   "primaryEmpLocDesc",        :limit => 128
    t.string   "spouseFirstName",          :limit => 22
    t.string   "spouseMiddleName",         :limit => 15
    t.string   "spouseLastName",           :limit => 30
    t.string   "spouseAccountNo",          :limit => 11
    t.string   "spouseEmail",              :limit => 50
    t.string   "fianceeFirstName",         :limit => 15
    t.string   "fianceeMiddleName",        :limit => 15
    t.string   "fianceeLastName",          :limit => 30
    t.string   "fianceeAccountno",         :limit => 11
    t.string   "isFianceeStaff",           :limit => 1
    t.datetime "fianceeJoinStaffDate"
    t.string   "isFianceeJoiningNS",       :limit => 1
    t.string   "joiningNS",                :limit => 1
    t.string   "homePhone",                :limit => 24
    t.string   "workPhone",                :limit => 24
    t.string   "mobilePhone",              :limit => 24
    t.string   "pager",                    :limit => 24
    t.string   "email",                    :limit => 50
    t.string   "isEmailSecure",            :limit => 1
    t.string   "url"
    t.datetime "newStaffTrainingdate"
    t.string   "fax",                      :limit => 24
    t.string   "note",                     :limit => 2048
    t.string   "region",                   :limit => 10
    t.string   "countryCode",              :limit => 3
    t.string   "ssn",                      :limit => 9
    t.string   "maritalStatus",            :limit => 1
    t.string   "deptId",                   :limit => 10
    t.string   "jobCode",                  :limit => 6
    t.string   "accountCode",              :limit => 25
    t.string   "compFreq",                 :limit => 1
    t.string   "compRate",                 :limit => 20
    t.string   "compChngAmt",              :limit => 21
    t.string   "jobTitle",                 :limit => 80
    t.string   "deptName",                 :limit => 30
    t.string   "coupleTitle",              :limit => 12
    t.string   "otherPhone",               :limit => 24
    t.string   "preferredName",            :limit => 50
    t.string   "namePrefix",               :limit => 4
    t.datetime "origHiredate"
    t.datetime "birthDate"
    t.datetime "marriageDate"
    t.datetime "hireDate"
    t.datetime "rehireDate"
    t.datetime "loaStartDate"
    t.datetime "loaEndDate"
    t.string   "loaReason",                :limit => 80
    t.integer  "severancePayMonthsReq"
    t.datetime "serviceDate"
    t.datetime "lastIncDate"
    t.datetime "jobEntryDate"
    t.datetime "deptEntryDate"
    t.datetime "reportingDate"
    t.string   "employmentType",           :limit => 20
    t.string   "resignationReason",        :limit => 80
    t.datetime "resignationDate"
    t.string   "contributionsToOtherAcct", :limit => 1
    t.string   "contributionsToAcntName",  :limit => 80
    t.string   "contributionsToAcntNo",    :limit => 11
    t.integer  "fk_primaryAddress"
    t.integer  "fk_secondaryAddress"
    t.integer  "fk_teamID"
    t.string   "isSecure",                 :limit => 1
    t.string   "isSupported",              :limit => 1
    t.string   "removedFromPeopleSoft",    :limit => 1,                                  :default => "N"
    t.string   "isNonUSStaff",             :limit => 1
    t.integer  "person_id"
    t.string   "middleName",               :limit => 30
    t.string   "paygroup",                 :limit => 3
    t.string   "idType",                   :limit => 2
    t.string   "statusDescr",              :limit => 30
    t.string   "internationalStatus",      :limit => 3
    t.decimal  "balance",                                  :precision => 9, :scale => 2
    t.string   "cccHrSendingDept",         :limit => 10
    t.string   "cccHrCaringDept",          :limit => 10
    t.string   "cccCaringMinistry",        :limit => 10
    t.string   "assignmentLength",         :limit => 4
  end

  add_index "ministry_staff", ["accountNo"], :name => "accountNo", :unique => true
  add_index "ministry_staff", ["firstName"], :name => "index_ministry_staff_on_firstName"
  add_index "ministry_staff", ["fk_primaryAddress"], :name => "index2"
  add_index "ministry_staff", ["fk_secondaryAddress"], :name => "index3"
  add_index "ministry_staff", ["fk_teamID"], :name => "index1"
  add_index "ministry_staff", ["lastName"], :name => "index4"
  add_index "ministry_staff", ["person_id"], :name => "ministry_staff_person_id_index"
  add_index "ministry_staff", ["region"], :name => "index5"

  create_table "simplesecuritymanager_user", :primary_key => "userID", :force => true do |t|
    t.string   "globallyUniqueID",          :limit => 80
    t.string   "username",                  :limit => 80,                     :null => false
    t.string   "email_deprecated",          :limit => 64
    t.string   "password",                  :limit => 80
    t.string   "passwordQuestion",          :limit => 200
    t.string   "passwordAnswer",            :limit => 200
    t.datetime "lastFailure"
    t.integer  "lastFailureCnt"
    t.datetime "lastLogin"
    t.datetime "createdOn"
    t.boolean  "emailVerified",                            :default => false, :null => false
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "developer"
    t.string   "facebook_hash"
    t.string   "facebook_username"
    t.integer  "fb_user_id",                :limit => 8
  end

  add_index "simplesecuritymanager_user", ["fb_user_id"], :name => "index_simplesecuritymanager_user_on_fb_user_id"
  add_index "simplesecuritymanager_user", ["globallyUniqueID"], :name => "globallyUniqueID", :unique => true
  add_index "simplesecuritymanager_user", ["username"], :name => "CK_simplesecuritymanager_user_username", :unique => true

  create_table "sp_answer_sheets", :force => true do |t|
    t.integer  "question_sheet_id", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "completed_at"
  end

  create_table "sp_answers", :force => true do |t|
    t.integer "answer_sheet_id", :null => false
    t.integer "question_id",     :null => false
    t.text    "value"
    t.string  "short_value"
    t.integer "size"
    t.string  "content_type"
    t.string  "filename"
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string  "thumbnail"
  end

  add_index "sp_answers", ["short_value"], :name => "index_sp_answers_on_short_value"

  create_table "sp_applications", :force => true do |t|
    t.integer  "person_id"
    t.integer  "project_id"
    t.integer  "designation_number"
    t.integer  "year"
    t.string   "status",                   :limit => 50
    t.integer  "preference1_id"
    t.integer  "preference2_id"
    t.integer  "preference3_id"
    t.integer  "preference4_id"
    t.integer  "preference5_id"
    t.integer  "current_project_queue_id"
    t.datetime "submitted_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "old_id"
    t.boolean  "apply_for_leadership"
    t.datetime "withdrawn_at"
    t.string   "su_code"
    t.boolean  "applicant_notified"
    t.integer  "account_balance"
    t.datetime "accepted_at"
    t.string   "previous_status"
  end

  add_index "sp_applications", ["person_id"], :name => "index_sp_applications_on_person_id"
  add_index "sp_applications", ["year"], :name => "index_sp_applications_on_year"

  create_table "sp_conditions", :force => true do |t|
    t.integer "question_sheet_id", :null => false
    t.integer "trigger_id",        :null => false
    t.string  "expression",        :null => false
    t.integer "toggle_page_id",    :null => false
    t.integer "toggle_id"
  end

  create_table "sp_donations", :force => true do |t|
    t.integer "designation_number", :null => false
    t.float   "amount",             :null => false
  end

  add_index "sp_donations", ["designation_number"], :name => "sp_donations_designation_number_index"

  create_table "sp_elements", :force => true do |t|
    t.integer "question_sheet_id",               :null => false
    t.integer "page_id",                         :null => false
    t.string  "kind",              :limit => 40, :null => false
    t.string  "style",             :limit => 40
    t.string  "label"
    t.text    "content"
    t.boolean "required"
    t.string  "slug",              :limit => 36
    t.integer "position"
    t.string  "object_name"
    t.string  "attribute_name"
    t.string  "source"
    t.string  "value_xpath"
    t.string  "text_xpath"
    t.integer "question_grid_id"
    t.string  "cols"
    t.boolean "is_confidential"
  end

  add_index "sp_elements", ["question_sheet_id", "position", "page_id"], :name => "index_sp_elements_on_question_sheet_id_and_position_and_page_id"
  add_index "sp_elements", ["slug"], :name => "index_sp_elements_on_slug"

  create_table "sp_elements_depreated", :force => true do |t|
    t.integer  "parent_id"
    t.string   "type",            :limit => 50
    t.text     "text"
    t.boolean  "is_required"
    t.string   "question_table",  :limit => 50
    t.string   "question_column", :limit => 50
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "dependency_id"
    t.integer  "max_length",                    :default => 0, :null => false
    t.boolean  "is_confidential"
  end

  create_table "sp_evaluations", :force => true do |t|
    t.integer "application_id",                        :null => false
    t.integer "spiritual_maturity", :default => 0
    t.integer "teachability",       :default => 0
    t.integer "leadership",         :default => 0
    t.integer "stability",          :default => 0
    t.integer "good_evangelism",    :default => 0
    t.integer "reason",             :default => 0
    t.integer "social_maturity",    :default => 0
    t.integer "ccc_involvement",    :default => 0
    t.boolean "charismatic",        :default => false
    t.boolean "morals",             :default => false
    t.boolean "drugs",              :default => false
    t.boolean "bad_evangelism",     :default => false
    t.boolean "authority",          :default => false
    t.boolean "eating",             :default => false
    t.text    "comments"
  end

  create_table "sp_gospel_in_actions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_ministry_focuses", :force => true do |t|
    t.string "name"
  end

  create_table "sp_ministry_focuses_projects", :id => false, :force => true do |t|
    t.integer "sp_project_id",        :default => 0, :null => false
    t.integer "sp_ministry_focus_id", :default => 0, :null => false
  end

  create_table "sp_page_elements", :force => true do |t|
    t.integer  "page_id"
    t.integer  "element_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_pages", :force => true do |t|
    t.integer "question_sheet_id",                                   :null => false
    t.string  "label",             :limit => 100,                    :null => false
    t.integer "number"
    t.boolean "no_cache",                         :default => false
    t.boolean "hidden",                           :default => false
  end

  add_index "sp_pages", ["question_sheet_id", "number"], :name => "page_number", :unique => true

  create_table "sp_pages_depreated", :force => true do |t|
    t.string   "title",         :limit => 50
    t.string   "url_name",      :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "hidden"
  end

  create_table "sp_payments", :force => true do |t|
    t.integer  "application_id"
    t.string   "payment_type"
    t.string   "amount"
    t.string   "payment_account_no"
    t.datetime "created_at"
    t.string   "auth_code"
    t.string   "status"
    t.datetime "updated_at"
  end

  create_table "sp_project_gospel_in_actions", :force => true do |t|
    t.integer  "gospel_in_action_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_project_versions", :force => true do |t|
    t.integer  "pd_id"
    t.integer  "apd_id"
    t.integer  "opd_id"
    t.string   "name",                         :limit => 50
    t.string   "city",                         :limit => 50
    t.string   "state",                        :limit => 50
    t.string   "country",                      :limit => 60
    t.string   "aoa",                          :limit => 50
    t.string   "display_location",             :limit => 100
    t.string   "primary_partner",              :limit => 100
    t.string   "secondary_partner",            :limit => 100
    t.boolean  "partner_region_only"
    t.string   "report_stats_to",              :limit => 50
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "weeks"
    t.integer  "primary_ministry_focus_id"
    t.boolean  "job"
    t.text     "description"
    t.string   "operating_business_unit",      :limit => 50
    t.string   "operating_operating_unit",     :limit => 50
    t.string   "operating_department",         :limit => 50
    t.string   "operating_project",            :limit => 50
    t.string   "operating_designation",        :limit => 50
    t.string   "scholarship_business_unit",    :limit => 50
    t.string   "scholarship_operating_unit",   :limit => 50
    t.string   "scholarship_department",       :limit => 50
    t.string   "scholarship_project",          :limit => 50
    t.string   "scholarship_designation",      :limit => 50
    t.integer  "staff_cost"
    t.integer  "intern_cost"
    t.integer  "student_cost"
    t.string   "departure_city",               :limit => 60
    t.datetime "date_of_departure"
    t.string   "destination_city",             :limit => 60
    t.datetime "date_of_return"
    t.text     "in_country_contact"
    t.string   "project_contact_name",         :limit => 50
    t.string   "project_contact_role",         :limit => 40
    t.string   "project_contact_phone",        :limit => 20
    t.string   "project_contact_email",        :limit => 100
    t.integer  "max_student_men_applicants",                   :default => 0,    :null => false
    t.integer  "max_student_women_applicants",                 :default => 0,    :null => false
    t.integer  "housing_capacity_men"
    t.integer  "housing_capacity_women"
    t.integer  "ideal_staff_men",                              :default => 0,    :null => false
    t.integer  "ideal_staff_women",                            :default => 0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "current_students_men",                         :default => 0
    t.integer  "current_students_women",                       :default => 0
    t.integer  "current_applicants_men",                       :default => 0
    t.integer  "current_applicants_women",                     :default => 0
    t.integer  "year"
    t.integer  "coordinator_id"
    t.integer  "old_id"
    t.string   "project_status"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "url",                          :limit => 1024
    t.string   "url_title"
    t.string   "ds_project_code",              :limit => 50
    t.integer  "sp_project_id"
    t.boolean  "show_on_website",                              :default => true
    t.datetime "apply_by_date"
    t.integer  "version"
    t.boolean  "use_provided_application",                     :default => true
    t.string   "tertiary_partner"
    t.date     "staff_start_date"
    t.date     "staff_end_date"
    t.string   "project_contact2_name"
    t.string   "project_contact2_role"
    t.string   "project_contact2_phone"
    t.string   "project_contact2_email"
  end

  add_index "sp_project_versions", ["aoa"], :name => "index_sp_project_versions_on_aoa"
  add_index "sp_project_versions", ["city"], :name => "index_sp_project_versions_on_city"
  add_index "sp_project_versions", ["country"], :name => "index_sp_project_versions_on_country"
  add_index "sp_project_versions", ["end_date"], :name => "index_sp_project_versions_on_end_date"
  add_index "sp_project_versions", ["name"], :name => "index_sp_project_versions_on_name"
  add_index "sp_project_versions", ["primary_ministry_focus_id"], :name => "index_sp_project_versions_on_primary_ministry_focus_id"
  add_index "sp_project_versions", ["primary_partner"], :name => "index_sp_project_versions_on_primary_partner"
  add_index "sp_project_versions", ["secondary_partner"], :name => "index_sp_project_versions_on_secondary_partner"
  add_index "sp_project_versions", ["sp_project_id"], :name => "index_sp_project_versions_on_sp_project_id"
  add_index "sp_project_versions", ["start_date"], :name => "index_sp_project_versions_on_start_date"
  add_index "sp_project_versions", ["year"], :name => "index_sp_project_versions_on_year"

  create_table "sp_projects", :force => true do |t|
    t.integer  "pd_id"
    t.integer  "apd_id"
    t.integer  "opd_id"
    t.string   "name",                         :limit => 50
    t.string   "city",                         :limit => 50
    t.string   "state",                        :limit => 50
    t.string   "country",                      :limit => 60
    t.string   "aoa",                          :limit => 50
    t.string   "display_location",             :limit => 100
    t.string   "primary_partner",              :limit => 100
    t.string   "secondary_partner",            :limit => 100
    t.boolean  "partner_region_only"
    t.string   "report_stats_to",              :limit => 50
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "weeks"
    t.integer  "primary_ministry_focus_id"
    t.boolean  "job"
    t.text     "description"
    t.string   "operating_business_unit",      :limit => 50
    t.string   "operating_operating_unit",     :limit => 50
    t.string   "operating_department",         :limit => 50
    t.string   "operating_project",            :limit => 50
    t.string   "operating_designation",        :limit => 50
    t.string   "scholarship_business_unit",    :limit => 50
    t.string   "scholarship_operating_unit",   :limit => 50
    t.string   "scholarship_department",       :limit => 50
    t.string   "scholarship_project",          :limit => 50
    t.string   "scholarship_designation",      :limit => 50
    t.integer  "staff_cost"
    t.integer  "intern_cost"
    t.integer  "student_cost"
    t.string   "departure_city",               :limit => 60
    t.date     "date_of_departure"
    t.string   "destination_city",             :limit => 60
    t.date     "date_of_return"
    t.text     "in_country_contact"
    t.string   "project_contact_name",         :limit => 50
    t.string   "project_contact_role",         :limit => 40
    t.string   "project_contact_phone",        :limit => 20
    t.string   "project_contact_email",        :limit => 100
    t.integer  "max_student_men_applicants",                   :default => 60,   :null => false
    t.integer  "max_student_women_applicants",                 :default => 60,   :null => false
    t.integer  "max_accepted_men"
    t.integer  "max_accepted_women"
    t.integer  "ideal_staff_men",                              :default => 0,    :null => false
    t.integer  "ideal_staff_women",                            :default => 0,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "current_students_men",                         :default => 0
    t.integer  "current_students_women",                       :default => 0
    t.integer  "current_applicants_men",                       :default => 0
    t.integer  "current_applicants_women",                     :default => 0
    t.integer  "year"
    t.integer  "coordinator_id"
    t.integer  "old_id"
    t.string   "project_status"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "url",                          :limit => 1024
    t.string   "url_title"
    t.string   "ds_project_code",              :limit => 50
    t.boolean  "show_on_website",                              :default => true
    t.datetime "apply_by_date"
    t.integer  "version"
    t.boolean  "use_provided_application",                     :default => true
    t.string   "tertiary_partner"
    t.date     "staff_start_date"
    t.date     "staff_end_date"
    t.string   "facebook_url"
    t.text     "student_quotes"
    t.string   "blog_url"
    t.string   "blog_title"
    t.string   "project_contact2_name"
    t.string   "project_contact2_role"
    t.string   "project_contact2_phone"
    t.string   "project_contact2_email"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  add_index "sp_projects", ["name"], :name => "sp_projects_name_index", :unique => true
  add_index "sp_projects", ["primary_partner"], :name => "primary_partner"
  add_index "sp_projects", ["project_status"], :name => "project_status"
  add_index "sp_projects", ["secondary_partner"], :name => "secondary_partner"
  add_index "sp_projects", ["year"], :name => "year"

  create_table "sp_question_options", :force => true do |t|
    t.integer  "question_id"
    t.string   "option",      :limit => 50
    t.string   "value",       :limit => 50
    t.integer  "position"
    t.datetime "created_at"
  end

  create_table "sp_question_sheets", :force => true do |t|
    t.string "label", :limit => 60, :null => false
  end

  create_table "sp_questionnaire_pages", :force => true do |t|
    t.integer  "questionnaire_id"
    t.integer  "page_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_references", :force => true do |t|
    t.integer  "application_id"
    t.string   "type",           :limit => 50
    t.datetime "email_sent_at"
    t.boolean  "is_staff"
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "accountNo"
    t.string   "home_phone"
    t.string   "email"
    t.string   "status"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "access_key"
    t.boolean  "mail",                         :default => false
  end

  add_index "sp_references", ["application_id"], :name => "application_id"

  create_table "sp_roles", :force => true do |t|
    t.string "role",       :limit => 50
    t.string "user_class"
  end

  create_table "sp_staff", :force => true do |t|
    t.integer "person_id",                                 :null => false
    t.integer "project_id",                                :null => false
    t.string  "type",       :limit => 100, :default => "", :null => false
    t.string  "year"
  end

  create_table "sp_stats", :force => true do |t|
    t.integer  "project_id"
    t.integer  "spiritual_conversations_initiated"
    t.integer  "gospel_shared"
    t.integer  "received_christ"
    t.integer  "holy_spirit_presentations"
    t.integer  "holy_spirit_filled"
    t.integer  "other_exposures"
    t.integer  "involved_new_believers"
    t.integer  "students_involved"
    t.integer  "spiritual_multipliers"
    t.string   "type",                              :limit => 50
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "gospel_shared_personal"
    t.integer  "gospel_shared_group"
    t.integer  "gospel_shared_media"
    t.integer  "pioneer_campuses"
    t.integer  "key_contact_campuses"
    t.integer  "launched_campuses"
    t.integer  "movements_launched"
  end

  create_table "sp_student_quotes", :force => true do |t|
    t.integer  "project_id"
    t.text     "quote"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_users", :force => true do |t|
    t.integer  "ssm_id"
    t.datetime "last_login"
    t.datetime "created_at"
    t.integer  "created_by_id"
    t.string   "type"
    t.string   "role"
    t.integer  "person_id"
  end

  add_index "sp_users", ["ssm_id"], :name => "sp_users_ssm_id_index", :unique => true

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end
