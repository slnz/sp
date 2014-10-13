# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140917195224) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: true do |t|
    t.string   "access_token"
    t.string   "user"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "authentications", ["uid", "provider"], name: "uid_provider", unique: true, using: :btree

  create_table "countries", force: true do |t|
    t.string  "country",  limit: 100
    t.string  "code",     limit: 10
    t.boolean "closed",               default: false
    t.string  "iso_code"
  end

  create_table "email_addresses", force: true do |t|
    t.string   "email"
    t.integer  "person_id"
    t.boolean  "primary",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

  create_table "ministries", force: true do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "global_registry_id"
  end

  create_table "ministry_activity", primary_key: "ActivityID", force: true do |t|
    t.string   "status",                   limit: 2
    t.date     "periodBegin"
    t.datetime "periodEnd_deprecated"
    t.string   "strategy",                 limit: 2
    t.string   "transUsername",            limit: 50
    t.integer  "fk_targetAreaID",                     null: false
    t.integer  "fk_teamID",                           null: false
    t.string   "statusHistory_deprecated", limit: 2
    t.string   "url"
    t.string   "facebook"
    t.integer  "sent_teamID"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gcx_site"
    t.string   "global_registry_id"
  end

  add_index "ministry_activity", ["fk_targetAreaID", "strategy"], name: "index_ministry_activity_on_fk_targetareaid_and_strategy", unique: true, using: :btree
  add_index "ministry_activity", ["fk_targetAreaID"], name: "fk_targetAreaID_idx", using: :btree

  create_table "ministry_locallevel", primary_key: "teamID", force: true do |t|
    t.string   "name",                   limit: 100
    t.string   "lane",                   limit: 10
    t.string   "note"
    t.string   "region",                 limit: 2
    t.string   "address1",               limit: 35
    t.string   "address2",               limit: 35
    t.string   "city",                   limit: 30
    t.string   "state",                  limit: 6
    t.string   "zip",                    limit: 10
    t.string   "country",                limit: 64
    t.string   "phone",                  limit: 24
    t.string   "fax",                    limit: 24
    t.string   "email",                  limit: 50
    t.string   "url"
    t.string   "isActive",               limit: 1
    t.datetime "startdate"
    t.datetime "stopdate"
    t.string   "Fk_OrgRel",              limit: 64
    t.string   "no",                     limit: 2
    t.string   "abbrv",                  limit: 2
    t.string   "hasMultiRegionalAccess"
    t.string   "dept_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

  add_index "ministry_locallevel", ["global_registry_id"], name: "index_ministry_locallevel_on_global_registry_id", using: :btree

  create_table "ministry_newaddress", force: true do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "address3",             limit: 55
    t.string   "address4",             limit: 55
    t.string   "city",                 limit: 50
    t.string   "state",                limit: 50
    t.string   "zip",                  limit: 15
    t.string   "country",              limit: 64
    t.string   "home_phone",           limit: 26
    t.string   "work_phone",           limit: 250
    t.string   "cell_phone",           limit: 25
    t.string   "fax",                  limit: 25
    t.string   "skype"
    t.string   "email",                limit: 200
    t.string   "url",                  limit: 100
    t.string   "contact_name"
    t.string   "contact_relationship", limit: 50
    t.string   "address_type",         limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "created_by",           limit: 50
    t.string   "changed_by",           limit: 50
    t.integer  "person_id"
    t.string   "email2",               limit: 200
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "facebook_link"
    t.string   "myspace_link"
    t.string   "title"
    t.string   "dorm"
    t.string   "room"
    t.string   "preferred_phone",      limit: 25
    t.string   "phone1_type",                      default: "cell"
    t.string   "phone2_type",                      default: "home"
    t.string   "phone3_type",                      default: "work"
    t.string   "global_registry_id",   limit: 40
  end

  add_index "ministry_newaddress", ["address_type", "person_id"], name: "unique_person_addressType", unique: true, using: :btree
  add_index "ministry_newaddress", ["address_type"], name: "index_ministry_newAddress_on_addressType", using: :btree
  add_index "ministry_newaddress", ["email"], name: "email", using: :btree
  add_index "ministry_newaddress", ["person_id"], name: "fk_PersonID", using: :btree

  create_table "ministry_person", force: true do |t|
    t.string   "account_no",                    limit: 11
    t.string   "last_name",                     limit: 50
    t.string   "first_name",                    limit: 50
    t.string   "middle_name",                   limit: 50
    t.string   "preferred_name",                limit: 50
    t.string   "gender",                        limit: 1
    t.string   "region",                        limit: 5
    t.boolean  "workInUS",                                                            default: true,  null: false
    t.boolean  "usCitizen",                                                           default: true,  null: false
    t.string   "citizenship",                   limit: 50
    t.boolean  "isStaff"
    t.string   "title",                         limit: 5
    t.string   "campus",                        limit: 128
    t.string   "universityState",               limit: 5
    t.string   "yearInSchool",                  limit: 20
    t.string   "major",                         limit: 70
    t.string   "minor",                         limit: 70
    t.string   "greekAffiliation",              limit: 50
    t.string   "maritalStatus",                 limit: 20
    t.string   "numberChildren",                limit: 2
    t.boolean  "isChild",                                                             default: false, null: false
    t.text     "bio"
    t.string   "image",                         limit: 100
    t.string   "occupation",                    limit: 50
    t.string   "blogfeed",                      limit: 200
    t.datetime "cruCommonsInvite"
    t.datetime "cruCommonsLastLogin"
    t.datetime "dateCreated"
    t.datetime "dateChanged"
    t.string   "createdBy",                     limit: 50
    t.string   "changedBy",                     limit: 50
    t.integer  "fk_ssmUserId"
    t.integer  "fk_StaffSiteProfileID"
    t.integer  "fk_spouseID"
    t.integer  "fk_childOf"
    t.date     "birth_date"
    t.date     "date_became_christian"
    t.date     "graduation_date"
    t.string   "level_of_school"
    t.string   "staff_notes"
    t.string   "donor_number",                  limit: 11
    t.string   "url",                           limit: 2000
    t.string   "isSecure",                      limit: 1
    t.integer  "primary_campus_involvement_id"
    t.integer  "mentor_id"
    t.string   "lastAttended",                  limit: 20
    t.string   "ministry"
    t.string   "strategy",                      limit: 20
    t.integer  "fb_uid",                        limit: 8
    t.datetime "date_attributes_updated"
    t.decimal  "balance_daily",                              precision: 10, scale: 2
    t.string   "siebel_contact_id"
    t.string   "sp_gcx_site"
    t.string   "global_registry_id"
  end

  add_index "ministry_person", ["account_no"], name: "accountNo_ministry_Person", using: :btree
  add_index "ministry_person", ["campus"], name: "campus", using: :btree
  add_index "ministry_person", ["fb_uid"], name: "index_ministry_person_on_fb_uid", using: :btree
  add_index "ministry_person", ["first_name", "last_name"], name: "firstName_lastName", using: :btree
  add_index "ministry_person", ["fk_spouseID"], name: "index_ministry_person_on_fk_spouseid", using: :btree
  add_index "ministry_person", ["fk_ssmUserId"], name: "fk_ssmUserId", using: :btree
  add_index "ministry_person", ["global_registry_id"], name: "index_ministry_person_on_global_registry_id", using: :btree
  add_index "ministry_person", ["last_name"], name: "lastname_ministry_Person", using: :btree
  add_index "ministry_person", ["region"], name: "region_ministry_Person", using: :btree
  add_index "ministry_person", ["siebel_contact_id"], name: "index_ministry_person_on_siebel_contact_id", using: :btree

  create_table "ministry_regionalteam", primary_key: "teamID", force: true do |t|
    t.string   "name",               limit: 100
    t.string   "note"
    t.string   "region",             limit: 2
    t.string   "address1",           limit: 35
    t.string   "address2",           limit: 35
    t.string   "city",               limit: 30
    t.string   "state",              limit: 6
    t.string   "zip",                limit: 10
    t.string   "country",            limit: 64
    t.string   "phone",              limit: 24
    t.string   "fax",                limit: 24
    t.string   "email",              limit: 50
    t.string   "url"
    t.string   "isActive",           limit: 1
    t.datetime "startdate"
    t.datetime "stopdate"
    t.string   "no",                 limit: 80
    t.string   "abbrv",              limit: 80
    t.string   "hrd",                limit: 50
    t.string   "spPhone",            limit: 24
    t.string   "global_registry_id"
  end

  create_table "ministry_staff", force: true do |t|
    t.string   "accountNo",                limit: 15,                                         null: false
    t.string   "firstName",                limit: 30
    t.string   "middleInitial",            limit: 1
    t.string   "lastName",                 limit: 30
    t.string   "isMale",                   limit: 1
    t.string   "position",                 limit: 30
    t.string   "countryStatus",            limit: 10
    t.string   "jobStatus",                limit: 60
    t.string   "ministry",                 limit: 35
    t.string   "strategy",                 limit: 20
    t.string   "isNewStaff",               limit: 1
    t.string   "primaryEmpLocState",       limit: 6
    t.string   "primaryEmpLocCountry",     limit: 64
    t.string   "primaryEmpLocCity",        limit: 35
    t.string   "primaryEmpLocDesc",        limit: 128
    t.string   "spouseFirstName",          limit: 22
    t.string   "spouseMiddleName",         limit: 15
    t.string   "spouseLastName",           limit: 30
    t.string   "spouseAccountNo",          limit: 11
    t.string   "spouseEmail",              limit: 50
    t.string   "fianceeFirstName",         limit: 15
    t.string   "fianceeMiddleName",        limit: 15
    t.string   "fianceeLastName",          limit: 30
    t.string   "fianceeAccountno",         limit: 11
    t.string   "isFianceeStaff",           limit: 1
    t.date     "fianceeJoinStaffDate"
    t.string   "isFianceeJoiningNS",       limit: 1
    t.string   "joiningNS",                limit: 1
    t.string   "homePhone",                limit: 24
    t.string   "workPhone",                limit: 24
    t.string   "mobilePhone",              limit: 24
    t.string   "pager",                    limit: 24
    t.string   "email",                    limit: 50
    t.string   "isEmailSecure",            limit: 1
    t.string   "url"
    t.date     "newStaffTrainingdate"
    t.string   "fax",                      limit: 24
    t.string   "note",                     limit: 2048
    t.string   "region",                   limit: 10
    t.string   "countryCode",              limit: 3
    t.string   "ssn",                      limit: 9
    t.string   "maritalStatus",            limit: 1
    t.string   "deptId",                   limit: 10
    t.string   "jobCode",                  limit: 6
    t.string   "accountCode",              limit: 25
    t.string   "compFreq",                 limit: 1
    t.decimal  "compRate",                              precision: 9, scale: 2
    t.string   "compChngAmt",              limit: 21
    t.string   "jobTitle",                 limit: 80
    t.string   "deptName",                 limit: 30
    t.string   "coupleTitle",              limit: 12
    t.string   "otherPhone",               limit: 24
    t.string   "preferredName",            limit: 50
    t.string   "namePrefix",               limit: 4
    t.date     "origHiredate"
    t.date     "birthDate"
    t.date     "marriageDate"
    t.date     "hireDate"
    t.date     "rehireDate"
    t.date     "loaStartDate"
    t.date     "loaEndDate"
    t.string   "loaReason",                limit: 80
    t.integer  "severancePayMonthsReq"
    t.date     "serviceDate"
    t.date     "lastIncDate"
    t.date     "jobEntryDate"
    t.date     "deptEntryDate"
    t.date     "reportingDate"
    t.string   "employmentType",           limit: 20
    t.string   "resignationReason",        limit: 80
    t.date     "resignationDate"
    t.string   "contributionsToOtherAcct", limit: 1
    t.string   "contributionsToAcntName",  limit: 80
    t.string   "contributionsToAcntNo",    limit: 11
    t.integer  "fk_primaryAddress"
    t.integer  "fk_secondaryAddress"
    t.integer  "fk_teamID"
    t.string   "isSecure",                 limit: 1
    t.string   "isSupported",              limit: 1
    t.string   "removedFromPeopleSoft",                                         default: "N"
    t.string   "isNonUSStaff",             limit: 1
    t.integer  "person_id"
    t.string   "middleName",               limit: 30
    t.string   "paygroup",                 limit: 3
    t.string   "idType",                   limit: 2
    t.string   "statusDescr",              limit: 30
    t.string   "internationalStatus",      limit: 3
    t.decimal  "balance",                               precision: 9, scale: 2
    t.string   "cccHrSendingDept",         limit: 10
    t.string   "cccHrCaringDept",          limit: 10
    t.string   "cccCaringMinistry",        limit: 10
    t.string   "assignmentLength",         limit: 4
    t.string   "relay_email",              limit: 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ministry_staff", ["accountNo"], name: "accountNo", unique: true, using: :btree
  add_index "ministry_staff", ["firstName"], name: "index_ministry_staff_on_firstName", using: :btree
  add_index "ministry_staff", ["person_id"], name: "ministry_staff_person_id_index", using: :btree

  create_table "ministry_statistic", primary_key: "StatisticID", force: true do |t|
    t.date     "periodBegin"
    t.date     "periodEnd"
    t.integer  "exposures"
    t.integer  "exposuresViaMedia"
    t.integer  "evangelisticOneOnOne"
    t.integer  "evangelisticGroup"
    t.integer  "decisions"
    t.integer  "attendedLastConf"
    t.integer  "invldNewBlvrs"
    t.integer  "invldStudents"
    t.integer  "invldFreshmen"
    t.integer  "invldSophomores"
    t.integer  "invldJuniors"
    t.integer  "invldSeniors"
    t.integer  "invldGrads"
    t.integer  "studentLeaders"
    t.integer  "volunteers"
    t.integer  "staff"
    t.integer  "nonStaffStint"
    t.integer  "staffStint"
    t.integer  "fk_Activity"
    t.integer  "multipliers"
    t.integer  "laborersSent"
    t.integer  "decisionsHelpedByMedia"
    t.integer  "decisionsHelpedByOneOnOne"
    t.integer  "decisionsHelpedByGroup"
    t.integer  "decisionsHelpedByOngoingReln"
    t.integer  "ongoingEvangReln"
    t.string   "updated_by"
    t.datetime "updated_at"
    t.string   "peopleGroup"
    t.integer  "holySpiritConversations"
    t.integer  "dollars_raised"
    t.integer  "sp_year"
    t.datetime "created_at"
    t.integer  "spiritual_conversations"
    t.integer  "faculty_sent"
    t.integer  "faculty_involved"
    t.integer  "faculty_engaged"
    t.integer  "faculty_leaders"
  end

  add_index "ministry_statistic", ["periodEnd", "fk_Activity", "peopleGroup"], name: "activityWeekPeopleGroup", unique: true, using: :btree

  create_table "ministry_targetarea", primary_key: "targetAreaID", force: true do |t|
    t.string   "name",                   limit: 100
    t.string   "address1",               limit: 35
    t.string   "address2",               limit: 35
    t.string   "city",                   limit: 30
    t.string   "state",                  limit: 32
    t.string   "zip",                    limit: 10
    t.string   "country",                limit: 64
    t.string   "phone",                  limit: 24
    t.string   "fax",                    limit: 24
    t.string   "email",                  limit: 50
    t.string   "url"
    t.string   "abbrv",                  limit: 32
    t.string   "fice",                   limit: 32
    t.string   "mainCampusFice",         limit: 32
    t.string   "isNoFiceOK",             limit: 1
    t.text     "note"
    t.string   "altName",                limit: 100
    t.string   "isSecure",               limit: 1
    t.string   "isClosed",               limit: 1
    t.string   "region"
    t.string   "mpta",                   limit: 30
    t.string   "urlToLogo"
    t.integer  "enrollment"
    t.string   "monthSchoolStarts",      limit: 10
    t.string   "monthSchoolStops",       limit: 10
    t.string   "isSemester",             limit: 1
    t.string   "isApproved",             limit: 1
    t.string   "aoaPriority",            limit: 10
    t.string   "aoa",                    limit: 100
    t.string   "ciaUrl"
    t.string   "infoUrl"
    t.string   "calendar",               limit: 50
    t.string   "program1",               limit: 50
    t.string   "program2",               limit: 50
    t.string   "program3",               limit: 50
    t.string   "program4",               limit: 50
    t.string   "program5",               limit: 50
    t.string   "emphasis",               limit: 50
    t.string   "sex",                    limit: 50
    t.string   "institutionType",        limit: 50
    t.string   "highestOffering",        limit: 65
    t.string   "affiliation",            limit: 50
    t.string   "carnegieClassification", limit: 100
    t.string   "irsStatus",              limit: 50
    t.integer  "establishedDate"
    t.integer  "tuition"
    t.datetime "modified"
    t.string   "eventType",              limit: 2
    t.integer  "eventKeyID"
    t.string   "type",                   limit: 20
    t.string   "county"
    t.boolean  "ongoing_special_event",                                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",                           precision: 11, scale: 7
    t.decimal  "longitude",                          precision: 11, scale: 7
    t.string   "global_registry_id"
    t.string   "gate"
  end

  add_index "ministry_targetarea", ["country"], name: "index4", using: :btree
  add_index "ministry_targetarea", ["isApproved"], name: "index2", using: :btree
  add_index "ministry_targetarea", ["isClosed"], name: "index7", using: :btree
  add_index "ministry_targetarea", ["isSecure"], name: "index5", using: :btree
  add_index "ministry_targetarea", ["name"], name: "index1", using: :btree
  add_index "ministry_targetarea", ["region"], name: "index6", using: :btree
  add_index "ministry_targetarea", ["state"], name: "index3", using: :btree

  create_table "phone_numbers", force: true do |t|
    t.string   "number"
    t.string   "extension"
    t.integer  "person_id"
    t.string   "location",           default: "mobile"
    t.boolean  "primary",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "txt_to_email"
    t.integer  "carrier_id"
    t.datetime "email_updated_at"
    t.string   "global_registry_id"
  end

  add_index "phone_numbers", ["carrier_id"], name: "index_phone_numbers_on_carrier_id", using: :btree
  add_index "phone_numbers", ["number"], name: "index_phone_numbers_on_number", using: :btree
  add_index "phone_numbers", ["person_id", "number"], name: "index_phone_numbers_on_person_id_and_number", using: :btree

  create_table "simplesecuritymanager_user", primary_key: "userID", force: true do |t|
    t.string   "globallyUniqueID",          limit: 80
    t.string   "username",                  limit: 200,                 null: false
    t.string   "password",                  limit: 80
    t.string   "passwordQuestion",          limit: 200
    t.string   "passwordAnswer",            limit: 200
    t.datetime "lastFailure"
    t.integer  "lastFailureCnt"
    t.datetime "lastLogin"
    t.datetime "createdOn"
    t.boolean  "emailVerified",                         default: false, null: false
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "developer"
    t.string   "facebook_hash"
    t.string   "facebook_username"
    t.integer  "fb_user_id",                limit: 8
    t.string   "password_reset_key"
    t.string   "email"
    t.string   "encrypted_password"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sign_in_at"
    t.string   "locale"
    t.integer  "checked_guid",              limit: 2,   default: 0,     null: false
    t.text     "settings"
    t.string   "needs_merge"
    t.string   "password_plain"
    t.integer  "global_registry_id",        limit: 8
  end

  add_index "simplesecuritymanager_user", ["email"], name: "index_simplesecuritymanager_user_on_email", unique: true, using: :btree
  add_index "simplesecuritymanager_user", ["fb_user_id"], name: "index_simplesecuritymanager_user_on_fb_user_id", using: :btree
  add_index "simplesecuritymanager_user", ["global_registry_id"], name: "index_simplesecuritymanager_user_on_global_registry_id", using: :btree
  add_index "simplesecuritymanager_user", ["globallyUniqueID"], name: "globallyUniqueID", unique: true, using: :btree
  add_index "simplesecuritymanager_user", ["username"], name: "CK_simplesecuritymanager_user_username", unique: true, using: :btree

  create_table "sp_answer_sheet_question_sheets", force: true do |t|
    t.integer  "answer_sheet_id"
    t.integer  "question_sheet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_answer_sheet_question_sheets", ["answer_sheet_id"], name: "index_sp_answer_sheet_question_sheets_on_answer_sheet_id", using: :btree
  add_index "sp_answer_sheet_question_sheets", ["question_sheet_id"], name: "index_sp_answer_sheet_question_sheets_on_question_sheet_id", using: :btree

  create_table "sp_answer_sheets", force: true do |t|
    t.integer  "question_sheet_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "completed_at"
  end

  create_table "sp_answers", force: true do |t|
    t.integer  "answer_sheet_id",         null: false
    t.integer  "question_id",             null: false
    t.text     "value"
    t.string   "short_value"
    t.integer  "attachment_file_size"
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_answers", ["answer_sheet_id"], name: "index_sp_answers_on_answer_sheet_id", using: :btree
  add_index "sp_answers", ["question_id", "answer_sheet_id"], name: "index_on_as_and_q", using: :btree
  add_index "sp_answers", ["question_id"], name: "index_sp_answers_on_question_id", using: :btree
  add_index "sp_answers", ["short_value"], name: "index_sp_answers_on_short_value", using: :btree

  create_table "sp_application_moves", force: true do |t|
    t.integer  "application_id"
    t.integer  "old_project_id"
    t.integer  "new_project_id"
    t.integer  "moved_by_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_application_moves", ["application_id"], name: "application_id", using: :btree
  add_index "sp_application_moves", ["moved_by_person_id"], name: "moved_by_person_id", using: :btree
  add_index "sp_application_moves", ["new_project_id"], name: "new_project_id", using: :btree
  add_index "sp_application_moves", ["old_project_id"], name: "old_project_id", using: :btree

  create_table "sp_applications", force: true do |t|
    t.integer  "person_id"
    t.integer  "project_id"
    t.integer  "designation_number"
    t.integer  "year"
    t.string   "status",                   limit: 50
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
    t.integer  "old_id",                   limit: 8
    t.boolean  "apply_for_leadership"
    t.datetime "withdrawn_at"
    t.string   "su_code"
    t.boolean  "applicant_notified"
    t.integer  "account_balance"
    t.datetime "accepted_at"
    t.string   "previous_status"
    t.string   "global_registry_id"
    t.boolean  "rm_liability_signed"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "sp_applications", ["global_registry_id"], name: "index_sp_applications_on_global_registry_id", using: :btree
  add_index "sp_applications", ["person_id"], name: "index_sp_applications_on_person_id", using: :btree
  add_index "sp_applications", ["year"], name: "index_sp_applications_on_year", using: :btree

  create_table "sp_conditions", force: true do |t|
    t.integer "question_sheet_id", null: false
    t.integer "trigger_id",        null: false
    t.string  "expression",        null: false
    t.integer "toggle_page_id",    null: false
    t.integer "toggle_id"
  end

  add_index "sp_conditions", ["question_sheet_id"], name: "question_sheet_id", using: :btree

  create_table "sp_designation_numbers", force: true do |t|
    t.integer  "person_id"
    t.integer  "project_id"
    t.string   "designation_number"
    t.integer  "account_balance",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year"
  end

  create_table "sp_donations", force: true do |t|
    t.string   "designation_number",                          null: false
    t.decimal  "amount",             precision: 10, scale: 2, null: false
    t.string   "people_id"
    t.string   "donor_name"
    t.date     "donation_date"
    t.string   "address1"
    t.string   "address2"
    t.string   "address3"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.string   "email_address"
    t.string   "medium_type"
    t.string   "donation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_donations", ["designation_number"], name: "index_sp_donations_on_designation_number", using: :btree
  add_index "sp_donations", ["designation_number"], name: "sp_donations_designation_number_index", using: :btree
  add_index "sp_donations", ["donation_date"], name: "index_sp_donations_on_donation_date", using: :btree
  add_index "sp_donations", ["donation_id"], name: "donation_id", unique: true, using: :btree

  create_table "sp_elements", force: true do |t|
    t.string   "kind",                      limit: 40,                 null: false
    t.string   "style",                     limit: 40
    t.text     "label"
    t.text     "content"
    t.boolean  "required"
    t.string   "slug",                      limit: 36
    t.integer  "position"
    t.string   "object_name"
    t.string   "attribute_name"
    t.string   "source"
    t.string   "value_xpath"
    t.string   "text_xpath"
    t.integer  "question_grid_id"
    t.string   "cols"
    t.boolean  "is_confidential"
    t.string   "total_cols"
    t.string   "css_id"
    t.string   "css_class"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "related_question_sheet_id"
    t.integer  "conditional_id"
    t.text     "tooltip"
    t.boolean  "hide_label",                           default: false
    t.boolean  "hide_option_labels",                   default: false
    t.integer  "max_length"
    t.string   "conditional_type"
    t.text     "conditional_answer"
  end

  add_index "sp_elements", ["conditional_id"], name: "index_sp_elements_on_conditional_id", using: :btree
  add_index "sp_elements", ["position"], name: "index_sp_elements_on_question_sheet_id_and_position_and_page_id", using: :btree
  add_index "sp_elements", ["question_grid_id"], name: "index_sp_elements_on_question_grid_id", using: :btree
  add_index "sp_elements", ["slug"], name: "index_sp_elements_on_slug", using: :btree

  create_table "sp_email_templates", force: true do |t|
    t.string   "name",       limit: 1000, null: false
    t.text     "content"
    t.boolean  "enabled"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_email_templates", ["name"], name: "index_sp_email_templates_on_name", using: :btree

  create_table "sp_evaluations", force: true do |t|
    t.integer "application_id",                     null: false
    t.integer "spiritual_maturity", default: 0
    t.integer "teachability",       default: 0
    t.integer "leadership",         default: 0
    t.integer "stability",          default: 0
    t.integer "good_evangelism",    default: 0
    t.integer "reason",             default: 0
    t.integer "social_maturity",    default: 0
    t.integer "ccc_involvement",    default: 0
    t.boolean "charismatic",        default: false
    t.boolean "morals",             default: false
    t.boolean "drugs",              default: false
    t.boolean "bad_evangelism",     default: false
    t.boolean "authority",          default: false
    t.boolean "eating",             default: false
    t.text    "comments"
  end

  create_table "sp_gospel_in_actions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

  create_table "sp_ministry_focuses", force: true do |t|
    t.string "name"
    t.string "global_registry_id"
  end

  create_table "sp_page_elements", force: true do |t|
    t.integer  "page_id"
    t.integer  "element_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_page_elements", ["element_id"], name: "element_id", using: :btree
  add_index "sp_page_elements", ["page_id"], name: "page_id", using: :btree

  create_table "sp_pages", force: true do |t|
    t.integer "question_sheet_id",                             null: false
    t.string  "label",             limit: 100,                 null: false
    t.integer "number"
    t.boolean "no_cache",                      default: false
    t.boolean "hidden",                        default: false
  end

  add_index "sp_pages", ["question_sheet_id", "number"], name: "page_number", using: :btree

  create_table "sp_payments", force: true do |t|
    t.integer  "application_id"
    t.string   "payment_type"
    t.string   "amount"
    t.string   "payment_account_no"
    t.datetime "created_at"
    t.string   "auth_code"
    t.string   "status"
    t.datetime "updated_at"
    t.string   "global_registry_id", limit: 40
  end

  create_table "sp_project_gospel_in_actions", force: true do |t|
    t.integer  "gospel_in_action_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

  add_index "sp_project_gospel_in_actions", ["gospel_in_action_id"], name: "gospel_in_action_id", using: :btree

  create_table "sp_project_ministry_focuses", force: true do |t|
    t.integer  "project_id",         default: 0, null: false
    t.integer  "ministry_focus_id",  default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

  create_table "sp_project_versions", force: true do |t|
    t.integer  "pd_id"
    t.integer  "apd_id"
    t.integer  "opd_id"
    t.string   "name",                         limit: 50
    t.string   "city",                         limit: 50
    t.string   "state",                        limit: 50
    t.string   "country",                      limit: 60
    t.string   "aoa",                          limit: 50
    t.string   "display_location",             limit: 100
    t.string   "primary_partner",              limit: 100
    t.string   "secondary_partner",            limit: 100
    t.boolean  "partner_region_only"
    t.string   "report_stats_to",              limit: 50
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "weeks"
    t.integer  "primary_ministry_focus_id"
    t.boolean  "job"
    t.text     "description"
    t.string   "operating_business_unit",      limit: 50
    t.string   "operating_operating_unit",     limit: 50
    t.string   "operating_department",         limit: 50
    t.string   "operating_project",            limit: 50
    t.string   "operating_designation",        limit: 50
    t.string   "scholarship_business_unit",    limit: 50
    t.string   "scholarship_operating_unit",   limit: 50
    t.string   "scholarship_department",       limit: 50
    t.string   "scholarship_project",          limit: 50
    t.string   "scholarship_designation",      limit: 50
    t.integer  "staff_cost"
    t.integer  "intern_cost"
    t.integer  "student_cost"
    t.string   "departure_city",               limit: 60
    t.datetime "date_of_departure"
    t.string   "destination_city",             limit: 60
    t.datetime "date_of_return"
    t.text     "in_country_contact"
    t.string   "project_contact_name",         limit: 50
    t.string   "project_contact_role",         limit: 40
    t.string   "project_contact_phone",        limit: 20
    t.string   "project_contact_email",        limit: 100
    t.integer  "max_student_men_applicants",                                          default: 0,    null: false
    t.integer  "max_student_women_applicants",                                        default: 0,    null: false
    t.integer  "housing_capacity_men"
    t.integer  "housing_capacity_women"
    t.integer  "ideal_staff_men",                                                     default: 0,    null: false
    t.integer  "ideal_staff_women",                                                   default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "current_students_men",                                                default: 0
    t.integer  "current_students_women",                                              default: 0
    t.integer  "current_applicants_men",                                              default: 0
    t.integer  "current_applicants_women",                                            default: 0
    t.integer  "year"
    t.integer  "coordinator_id"
    t.integer  "old_id"
    t.string   "project_status"
    t.decimal  "latitude",                                  precision: 65, scale: 0
    t.decimal  "longitude",                                 precision: 65, scale: 0
    t.string   "url",                          limit: 1024
    t.string   "url_title"
    t.string   "ds_project_code",              limit: 50
    t.integer  "sp_project_id"
    t.boolean  "show_on_website",                                                     default: true
    t.datetime "apply_by_date"
    t.integer  "version"
    t.boolean  "use_provided_application",                                            default: true
    t.string   "tertiary_partner"
    t.date     "staff_start_date"
    t.date     "staff_end_date"
    t.string   "project_contact2_name"
    t.string   "project_contact2_role"
    t.string   "project_contact2_phone"
    t.string   "project_contact2_email"
  end

  add_index "sp_project_versions", ["aoa"], name: "index_sp_project_versions_on_aoa", using: :btree
  add_index "sp_project_versions", ["city"], name: "index_sp_project_versions_on_city", using: :btree
  add_index "sp_project_versions", ["country"], name: "index_sp_project_versions_on_country", using: :btree
  add_index "sp_project_versions", ["end_date"], name: "index_sp_project_versions_on_end_date", using: :btree
  add_index "sp_project_versions", ["name"], name: "index_sp_project_versions_on_name", using: :btree
  add_index "sp_project_versions", ["primary_ministry_focus_id"], name: "index_sp_project_versions_on_primary_ministry_focus_id", using: :btree
  add_index "sp_project_versions", ["primary_partner"], name: "index_sp_project_versions_on_primary_partner", using: :btree
  add_index "sp_project_versions", ["secondary_partner"], name: "index_sp_project_versions_on_secondary_partner", using: :btree
  add_index "sp_project_versions", ["sp_project_id"], name: "index_sp_project_versions_on_sp_project_id", using: :btree
  add_index "sp_project_versions", ["start_date"], name: "index_sp_project_versions_on_start_date", using: :btree
  add_index "sp_project_versions", ["year"], name: "index_sp_project_versions_on_year", using: :btree

  create_table "sp_projects", force: true do |t|
    t.integer  "pd_id"
    t.integer  "apd_id"
    t.integer  "opd_id"
    t.string   "name",                               limit: 200
    t.string   "city",                               limit: 50
    t.string   "state",                              limit: 50
    t.string   "country",                            limit: 60
    t.string   "world_region",                       limit: 50
    t.string   "display_location",                   limit: 100
    t.string   "primary_partner",                    limit: 100
    t.string   "secondary_partner",                  limit: 100
    t.boolean  "partner_region_only"
    t.string   "report_stats_to",                    limit: 50
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "weeks"
    t.integer  "primary_ministry_focus_id"
    t.boolean  "job"
    t.text     "description"
    t.string   "operating_business_unit",            limit: 50
    t.string   "operating_operating_unit",           limit: 50
    t.string   "operating_department",               limit: 50
    t.string   "operating_project",                  limit: 50
    t.string   "operating_designation",              limit: 50
    t.string   "scholarship_business_unit",          limit: 50
    t.string   "scholarship_operating_unit",         limit: 50
    t.string   "scholarship_department",             limit: 50
    t.string   "scholarship_project",                limit: 50
    t.string   "scholarship_designation",            limit: 50
    t.integer  "staff_cost"
    t.integer  "intern_cost"
    t.integer  "student_cost"
    t.string   "departure_city",                     limit: 60
    t.date     "date_of_departure"
    t.string   "destination_city",                   limit: 60
    t.date     "date_of_return"
    t.text     "in_country_contact"
    t.string   "medical_clinic"
    t.string   "medical_clinic_location"
    t.string   "project_contact_name",               limit: 50
    t.string   "project_contact_role",               limit: 40
    t.string   "project_contact_phone",              limit: 20
    t.string   "project_contact_email",              limit: 100
    t.integer  "max_student_men_applicants",                      default: 70,    null: false
    t.integer  "max_student_women_applicants",                    default: 70,    null: false
    t.integer  "max_accepted_men"
    t.integer  "max_accepted_women"
    t.integer  "ideal_staff_men",                                 default: 0,     null: false
    t.integer  "ideal_staff_women",                               default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "current_students_men",                            default: 0
    t.integer  "current_students_women",                          default: 0
    t.integer  "current_applicants_men",                          default: 0
    t.integer  "current_applicants_women",                        default: 0
    t.integer  "year",                                                            null: false
    t.integer  "coordinator_id"
    t.integer  "old_id"
    t.string   "project_status"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "url",                                limit: 1024
    t.string   "url_title"
    t.string   "ds_project_code",                    limit: 50
    t.boolean  "show_on_website",                                 default: true
    t.date     "apply_by_date"
    t.integer  "version"
    t.boolean  "use_provided_application",                        default: true
    t.string   "tertiary_partner"
    t.date     "staff_start_date"
    t.date     "staff_end_date"
    t.string   "facebook_url"
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
    t.integer  "basic_info_question_sheet_id"
    t.integer  "template_question_sheet_id"
    t.integer  "project_specific_question_sheet_id"
    t.boolean  "high_school",                                     default: false
    t.date     "pd_start_date"
    t.date     "pd_end_date"
    t.date     "pd_close_start_date"
    t.date     "pd_close_end_date"
    t.date     "student_staff_start_date"
    t.date     "student_staff_end_date"
    t.boolean  "background_checks_required",                      default: false
    t.date     "open_application_date"
    t.date     "archive_project_date"
    t.boolean  "secure"
    t.string   "global_registry_id"
    t.text     "project_summary"
    t.text     "full_project_description"
  end

  add_index "sp_projects", ["apd_id"], name: "apd_id", using: :btree
  add_index "sp_projects", ["coordinator_id"], name: "coordinator_id", using: :btree
  add_index "sp_projects", ["created_by_id"], name: "created_by_id", using: :btree
  add_index "sp_projects", ["global_registry_id"], name: "index_sp_projects_on_global_registry_id", using: :btree
  add_index "sp_projects", ["name"], name: "sp_projects_name_index", unique: true, using: :btree
  add_index "sp_projects", ["opd_id"], name: "opd_id", using: :btree
  add_index "sp_projects", ["pd_id"], name: "pd_id", using: :btree
  add_index "sp_projects", ["primary_partner"], name: "primary_partner", using: :btree
  add_index "sp_projects", ["project_status"], name: "project_status", using: :btree
  add_index "sp_projects", ["secondary_partner"], name: "secondary_partner", using: :btree
  add_index "sp_projects", ["updated_by_id"], name: "updated_by_id", using: :btree
  add_index "sp_projects", ["year"], name: "year", using: :btree

  create_table "sp_question_options", force: true do |t|
    t.integer  "question_id"
    t.string   "option",      limit: 50
    t.string   "value",       limit: 50
    t.integer  "position"
    t.datetime "created_at"
  end

  create_table "sp_question_sheets", force: true do |t|
    t.string  "label",    limit: 1000,                 null: false
    t.boolean "archived",              default: false
  end

  create_table "sp_questionnaire_pages", force: true do |t|
    t.integer  "questionnaire_id"
    t.integer  "page_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_references", force: true do |t|
    t.integer  "question_id"
    t.integer  "applicant_answer_sheet_id"
    t.datetime "email_sent_at"
    t.string   "relationship"
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "email"
    t.string   "status"
    t.datetime "submitted_at"
    t.string   "access_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_staff",                  default: false
    t.datetime "started_at"
  end

  add_index "sp_references", ["question_id"], name: "question_id", using: :btree

  create_table "sp_roles", force: true do |t|
    t.string "role",       limit: 50
    t.string "user_class"
  end

  create_table "sp_staff", force: true do |t|
    t.integer  "person_id",                                   null: false
    t.integer  "project_id",                                  null: false
    t.string   "type",               limit: 100, default: "", null: false
    t.integer  "year"
    t.string   "global_registry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sp_staff", ["project_id", "type", "year"], name: "project_staff_type", using: :btree

  create_table "sp_stats", force: true do |t|
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
    t.string   "type",                              limit: 50
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
    t.string   "global_registry_id"
  end

  create_table "sp_student_quotes", force: true do |t|
    t.integer  "project_id"
    t.text     "quote"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

  add_index "sp_student_quotes", ["project_id"], name: "project_id", using: :btree

  create_table "sp_users", force: true do |t|
    t.integer  "ssm_id"
    t.datetime "last_login"
    t.datetime "created_at"
    t.integer  "created_by_id"
    t.string   "type"
    t.integer  "person_id"
    t.string   "global_registry_id"
  end

  add_index "sp_users", ["person_id"], name: "person_id", using: :btree
  add_index "sp_users", ["ssm_id"], name: "sp_users_ssm_id_index", unique: true, using: :btree

  create_table "sp_world_regions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "global_registry_id"
  end

end
