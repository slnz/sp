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

ActiveRecord::Schema.define(:version => 20101123130420) do

  create_table "academic_departments", :force => true do |t|
    t.string "name"
  end

  create_table "am_friends_people_deprecated", :id => false, :force => true do |t|
    t.integer "friend_id", :null => false
    t.integer "person_id", :null => false
  end

# Could not dump table "am_group_links_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104ade238>

# Could not dump table "am_group_messages_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104acf8f0>

# Could not dump table "am_groups_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104abf5b8>

  create_table "am_groups_people_deprecated", :id => false, :force => true do |t|
    t.integer  "person_id",  :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_on"
  end

# Could not dump table "am_personal_links_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104a9fbc8>

  create_table "aoas", :force => true do |t|
    t.string "name"
  end

# Could not dump table "ap_signup_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104a8c550>

# Could not dump table "authentications" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104a7d960>

  create_table "cms_assoc_filecategory", :id => false, :force => true do |t|
    t.string  "CmsFileID",     :limit => 64,                   :null => false
    t.string  "CmsCategoryID", :limit => 64,                   :null => false
    t.boolean "dbioDummy",                   :default => true
  end

# Could not dump table "cms_cmscategory" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010495b2d0>

# Could not dump table "cms_cmsfile" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001048fead0>

  create_table "cms_viewcategoryidfiles", :id => false, :force => true do |t|
    t.integer  "CmsFileID",                     :default => 0, :null => false
    t.string   "mime",          :limit => 128
    t.string   "title",         :limit => 256
    t.integer  "accessCount"
    t.datetime "dateAdded"
    t.datetime "dateModified"
    t.string   "moderatedYet",  :limit => 1
    t.string   "summary",       :limit => 4000
    t.string   "quality",       :limit => 256
    t.datetime "expDate"
    t.datetime "lastAccessed"
    t.string   "modMsg",        :limit => 4000
    t.string   "keywords",      :limit => 4000
    t.string   "url",           :limit => 128
    t.string   "detail",        :limit => 4000
    t.string   "language",      :limit => 128
    t.string   "version",       :limit => 128
    t.string   "author",        :limit => 256
    t.string   "submitter",     :limit => 256
    t.string   "contact",       :limit => 256
    t.integer  "rating"
    t.string   "CmsCategoryID", :limit => 64,                  :null => false
  end

  create_table "cms_viewfileidcategories", :id => false, :force => true do |t|
    t.integer "CmsCategoryID",                  :default => 0, :null => false
    t.integer "parentCategory"
    t.string  "catName",        :limit => 256
    t.string  "catDesc",        :limit => 2000
    t.string  "path",           :limit => 2000
    t.string  "pathid",         :limit => 2000
    t.string  "CmsFileID",      :limit => 64,                  :null => false
  end

  create_table "cms_viewfilesandcategories", :id => false, :force => true do |t|
    t.integer  "CmsFileID",                      :default => 0, :null => false
    t.string   "mime",           :limit => 128
    t.string   "title",          :limit => 256
    t.integer  "accessCount"
    t.datetime "dateAdded"
    t.datetime "dateModified"
    t.string   "moderatedYet",   :limit => 1
    t.string   "summary",        :limit => 4000
    t.string   "quality",        :limit => 256
    t.datetime "expDate"
    t.datetime "lastAccessed"
    t.string   "modMsg",         :limit => 4000
    t.string   "keywords",       :limit => 4000
    t.string   "url",            :limit => 128
    t.string   "detail",         :limit => 4000
    t.string   "language",       :limit => 128
    t.string   "version",        :limit => 128
    t.string   "author",         :limit => 256
    t.string   "submitter",      :limit => 256
    t.string   "contact",        :limit => 256
    t.integer  "rating"
    t.integer  "CmsCategoryID",                  :default => 0, :null => false
    t.integer  "parentCategory"
    t.string   "catName",        :limit => 256
    t.string   "catDesc",        :limit => 2000
    t.string   "path",           :limit => 2000
    t.string   "pathid",         :limit => 2000
  end

# Could not dump table "counties" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102f58d10>

  create_table "countries", :force => true do |t|
    t.string  "country",  :limit => 100
    t.string  "code",     :limit => 10
    t.boolean "closed",                  :default => false
    t.string  "iso_code"
  end

# Could not dump table "crs2_additional_expenses_item" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102f0e170>

# Could not dump table "crs2_additional_info_item" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102eee3c0>

# Could not dump table "crs2_answer" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102edf320>

# Could not dump table "crs2_conference" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102ea4090>

# Could not dump table "crs2_configuration" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e959c8>

# Could not dump table "crs2_custom_questions_item" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e83020>

# Could not dump table "crs2_custom_stylesheet" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e74f48>

# Could not dump table "crs2_expense" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e601b0>

# Could not dump table "crs2_expense_selection" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e52588>

# Could not dump table "crs2_module_usage" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e43a10>

  create_table "crs2_person", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",            :null => false
    t.datetime "birth_date"
    t.string   "campus"
    t.string   "current_address1"
    t.string   "current_address2"
    t.string   "current_city"
    t.string   "current_country"
    t.string   "current_phone"
    t.string   "current_state"
    t.string   "current_zip"
    t.string   "email"
    t.string   "first_name"
    t.string   "gender"
    t.datetime "graduation_date"
    t.string   "greek_affiliation"
    t.string   "last_name"
    t.string   "major"
    t.string   "marital_status"
    t.string   "middle_name"
    t.string   "permanent_address1"
    t.string   "permanent_address2"
    t.string   "permanent_city"
    t.string   "permanent_country"
    t.string   "permanent_phone"
    t.string   "permanent_state"
    t.string   "permanent_zip"
    t.string   "university_state"
    t.string   "year_in_school"
  end

# Could not dump table "crs2_profile" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e07498>

# Could not dump table "crs2_profile_question" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102df78e0>

# Could not dump table "crs2_question" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102de39f8>

# Could not dump table "crs2_question_option" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102dd07e0>

# Could not dump table "crs2_registrant" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102da95c8>

# Could not dump table "crs2_registrant_type" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d48110>

# Could not dump table "crs2_registration" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d30a88>

# Could not dump table "crs2_transaction" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102cfbe50>

  create_table "crs2_url_base", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                                 :null => false
    t.string   "authority",               :default => "", :null => false
    t.string   "scheme",     :limit => 5, :default => "", :null => false
  end

  create_table "crs2_user", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",    :null => false
    t.datetime "last_login"
  end

# Could not dump table "crs2_user_role" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102ccbea8>

# Could not dump table "crs_answer" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102cc3cd0>

# Could not dump table "crs_childregistration" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102cb38d0>

  create_table "crs_conference", :primary_key => "conferenceID", :force => true do |t|
    t.datetime "createDate"
    t.string   "attributesAsked",          :limit => 30
    t.string   "name",                     :limit => 64
    t.string   "theme",                    :limit => 128
    t.string   "password",                 :limit => 20
    t.string   "staffPassword",            :limit => 20
    t.string   "region",                   :limit => 3
    t.string   "briefDescription",         :limit => 8000
    t.string   "contactName",              :limit => 60
    t.string   "contactEmail",             :limit => 50
    t.string   "contactPhone",             :limit => 24
    t.string   "contactAddress1",          :limit => 35
    t.string   "contactAddress2",          :limit => 35
    t.string   "contactCity",              :limit => 30
    t.string   "contactState",             :limit => 6
    t.string   "contactZip",               :limit => 10
    t.string   "splashPageURL",            :limit => 128
    t.string   "confImageId",              :limit => 64
    t.string   "fontFace",                 :limit => 64
    t.string   "backgroundColor",          :limit => 6
    t.string   "foregroundColor",          :limit => 6
    t.string   "highlightColor",           :limit => 6
    t.string   "confirmationEmail",        :limit => 4000
    t.string   "acceptCreditCards",        :limit => 1
    t.string   "acceptEChecks",            :limit => 1
    t.string   "acceptScholarships",       :limit => 1
    t.string   "authnetPassword",          :limit => 200
    t.datetime "preRegStart"
    t.datetime "preRegEnd"
    t.datetime "defaultDateStaffArrive"
    t.datetime "defaultDateStaffLeave"
    t.datetime "defaultDateGuestArrive"
    t.datetime "defaultDateGuestLeave"
    t.datetime "defaultDateStudentArrive"
    t.datetime "defaultDateStudentLeave"
    t.datetime "masterDefaultDateArrive"
    t.datetime "masterDefaultDateLeave"
    t.string   "ministryType",             :limit => 2
    t.string   "isCloaked",                :limit => 1
    t.float    "onsiteCost"
    t.float    "commuterCost"
    t.float    "preRegDeposit"
    t.float    "discountFullPayment"
    t.float    "discountEarlyReg"
    t.datetime "discountEarlyRegDate"
    t.string   "checkPayableTo",           :limit => 40
    t.string   "merchantAcctNum",          :limit => 64
    t.string   "backgroundColor3",         :limit => 6
    t.string   "backgroundColor2",         :limit => 6
    t.string   "highlightColor2",          :limit => 6
    t.string   "requiredColor",            :limit => 6
    t.string   "acceptVisa",               :limit => 1
    t.string   "acceptMasterCard",         :limit => 1
    t.string   "acceptAmericanExpress",    :limit => 1
    t.string   "acceptDiscover",           :limit => 1
    t.integer  "staffProfileNumber"
    t.integer  "staffProfileReqNumber"
    t.integer  "guestProfileNumber"
    t.integer  "guestProfileReqNumber"
    t.integer  "studentProfileNumber"
    t.integer  "studentProfileReqNumber"
    t.string   "askStudentChildren",       :limit => 1
    t.string   "askStaffChildren",         :limit => 1
    t.string   "askGuestChildren",         :limit => 1
    t.string   "studentLabel",             :limit => 64
    t.string   "staffLabel",               :limit => 64
    t.string   "guestLabel",               :limit => 64
    t.string   "studentDesc"
    t.string   "staffDesc"
    t.string   "guestDesc"
    t.string   "askStudentSpouse",         :limit => 1
    t.string   "askStaffSpouse",           :limit => 1
    t.string   "askGuestSpouse",           :limit => 1
  end

# Could not dump table "crs_customitem" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102bd8cf8>

# Could not dump table "crs_merchandise" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102bb3520>

  create_table "crs_merchandisechoice", :id => false, :force => true do |t|
    t.integer "fk_MerchandiseID",  :null => false
    t.integer "fk_RegistrationID", :null => false
  end

# Could not dump table "crs_payment" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b79c80>

# Could not dump table "crs_question" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b64498>

  create_table "crs_questiontext", :primary_key => "questionTextID", :force => true do |t|
    t.string  "body",       :limit => 7000
    t.string  "answerType", :limit => 50
    t.string  "status",     :limit => 50
    t.integer "oldID"
  end

# Could not dump table "crs_registration" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b38d20>

# Could not dump table "crs_registrationtype" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102aea440>

  create_table "crs_report", :primary_key => "reportID", :force => true do |t|
    t.string  "query",       :limit => 1000
    t.string  "xsl"
    t.string  "name"
    t.integer "reportGroup"
    t.string  "sorts",       :limit => 1000
    t.string  "sortNames",   :limit => 1000
  end

  create_table "crs_viewmerchandisechoice", :id => false, :force => true do |t|
    t.integer  "registrationID",                       :default => 0, :null => false
    t.datetime "registrationDate"
    t.string   "preRegistered",         :limit => 1
    t.integer  "fk_PersonID"
    t.integer  "displayOrder"
    t.string   "registrationType",      :limit => 50
    t.string   "required",              :limit => 1
    t.float    "amount"
    t.string   "note"
    t.string   "name",                  :limit => 128
    t.integer  "merchandiseID",                        :default => 0, :null => false
    t.integer  "fk_ConferenceID"
    t.integer  "fk_RegistrationTypeID"
  end

  create_table "crs_viewquestion", :id => false, :force => true do |t|
    t.string  "registrationType",      :limit => 50
    t.string  "required",              :limit => 1
    t.integer "displayOrder"
    t.integer "fk_ConferenceID"
    t.string  "body",                  :limit => 7000
    t.string  "answerType",            :limit => 50
    t.string  "status",                :limit => 50
    t.integer "questionID",                            :default => 0, :null => false
    t.integer "fk_QuestionTextID"
    t.integer "questionTextID",                        :default => 0, :null => false
    t.integer "fk_RegistrationTypeID"
  end

  create_table "crs_viewregistration", :id => false, :force => true do |t|
    t.string   "preRegistered",         :limit => 1
    t.datetime "registrationDate"
    t.integer  "registrationID",                       :default => 0, :null => false
    t.integer  "fk_ConferenceID"
    t.datetime "createdDate"
    t.string   "firstName",             :limit => 50
    t.string   "lastName",              :limit => 50
    t.string   "middleInitial",         :limit => 50
    t.datetime "birth_date"
    t.string   "campus",                :limit => 128
    t.string   "yearInSchool",          :limit => 20
    t.datetime "graduation_date"
    t.string   "greekAffiliation",      :limit => 50
    t.integer  "personID",                             :default => 0
    t.string   "gender",                :limit => 1
    t.string   "address1",              :limit => 55
    t.string   "address2",              :limit => 55
    t.string   "city",                  :limit => 50
    t.string   "state",                 :limit => 50
    t.string   "zip",                   :limit => 15
    t.string   "homePhone",             :limit => 25
    t.string   "country",               :limit => 64
    t.string   "email",                 :limit => 200
    t.string   "permanentAddress1",     :limit => 55
    t.string   "permanentAddress2",     :limit => 55
    t.string   "permanentCity",         :limit => 50
    t.string   "permanentState",        :limit => 50
    t.string   "permanentZip",          :limit => 15
    t.string   "permanentPhone",        :limit => 25
    t.string   "permanentCountry",      :limit => 64
    t.string   "maritalStatus",         :limit => 20
    t.string   "numberOfKids",          :limit => 2
    t.integer  "fk_PersonID"
    t.string   "accountNo",             :limit => 11
    t.integer  "additionalRooms"
    t.datetime "leaveDate"
    t.datetime "arriveDate"
    t.integer  "spouseID"
    t.integer  "spouseComing"
    t.integer  "spouseRegistrationID"
    t.string   "registeredFirst",       :limit => 1
    t.string   "isOnsite",              :limit => 1
    t.integer  "fk_RegistrationTypeID"
    t.string   "registrationType",      :limit => 64
    t.integer  "newPersonID"
  end

  create_table "crs_viewregistrationlocallevel", :id => false, :force => true do |t|
    t.integer  "registrationID",                       :default => 0, :null => false
    t.datetime "registrationDate"
    t.string   "registrationType",      :limit => 80
    t.string   "preRegistered",         :limit => 1
    t.integer  "fk_PersonID"
    t.integer  "fk_ConferenceID"
    t.string   "lastName",              :limit => 50
    t.integer  "personID",                             :default => 0, :null => false
    t.datetime "createdDate"
    t.string   "firstName",             :limit => 50
    t.string   "middleInitial",         :limit => 50
    t.datetime "birth_date"
    t.string   "campus",                :limit => 128
    t.string   "yearInSchool",          :limit => 20
    t.datetime "graduation_date"
    t.string   "greekAffiliation",      :limit => 50
    t.string   "gender",                :limit => 1
    t.string   "address1",              :limit => 55
    t.string   "address2",              :limit => 55
    t.string   "city",                  :limit => 50
    t.string   "state",                 :limit => 50
    t.string   "zip",                   :limit => 15
    t.string   "homePhone",             :limit => 25
    t.string   "country",               :limit => 64
    t.string   "email",                 :limit => 200
    t.string   "permanentAddress1",     :limit => 55
    t.string   "permanentAddress2",     :limit => 55
    t.string   "permanentCity",         :limit => 50
    t.string   "permanentState",        :limit => 50
    t.string   "permanentZip",          :limit => 15
    t.string   "permanentPhone",        :limit => 25
    t.string   "permanentCountry",      :limit => 64
    t.string   "maritalStatus",         :limit => 20
    t.string   "numberOfKids",          :limit => 2
    t.integer  "localLevelId",                         :default => 0, :null => false
    t.string   "region",                :limit => 2
    t.string   "llstate",               :limit => 6
    t.string   "accountNo",             :limit => 11
    t.integer  "additionalRooms"
    t.datetime "leaveDate"
    t.datetime "arriveDate"
    t.integer  "fk_RegistrationTypeID"
    t.integer  "spouseComing"
    t.integer  "spouseRegistrationID"
    t.string   "registeredFirst",       :limit => 1
    t.string   "isOnsite",              :limit => 1
    t.integer  "spouseID"
    t.integer  "newPersonID"
  end

  create_table "crs_viewregistrationtargetarea", :id => false, :force => true do |t|
    t.integer  "registrationID",                       :default => 0, :null => false
    t.datetime "registrationDate"
    t.string   "registrationType",      :limit => 80
    t.string   "preRegistered",         :limit => 1
    t.integer  "fk_PersonID"
    t.integer  "fk_ConferenceID"
    t.string   "lastName",              :limit => 50
    t.integer  "personID",                             :default => 0, :null => false
    t.datetime "createdDate"
    t.string   "firstName",             :limit => 50
    t.string   "middleInitial",         :limit => 50
    t.datetime "birth_date"
    t.string   "campus",                :limit => 128
    t.string   "yearInSchool",          :limit => 20
    t.datetime "graduation_date"
    t.string   "greekAffiliation",      :limit => 50
    t.string   "gender",                :limit => 1
    t.string   "address1",              :limit => 55
    t.string   "address2",              :limit => 55
    t.string   "city",                  :limit => 50
    t.string   "state",                 :limit => 50
    t.string   "zip",                   :limit => 15
    t.string   "homePhone",             :limit => 25
    t.string   "country",               :limit => 64
    t.string   "email",                 :limit => 200
    t.string   "permanentAddress1",     :limit => 55
    t.string   "permanentAddress2",     :limit => 55
    t.string   "permanentCity",         :limit => 50
    t.string   "permanentState",        :limit => 50
    t.string   "permanentZip",          :limit => 15
    t.string   "permanentPhone",        :limit => 25
    t.string   "permanentCountry",      :limit => 64
    t.string   "maritalStatus",         :limit => 20
    t.string   "numberOfKids",          :limit => 2
    t.string   "campusName",            :limit => 100
    t.string   "tastate",               :limit => 32
    t.integer  "additionalRooms"
    t.datetime "leaveDate"
    t.datetime "arriveDate"
    t.string   "accountNo",             :limit => 11
    t.integer  "fk_RegistrationTypeID"
    t.integer  "spouseComing"
    t.integer  "spouseRegistrationID"
    t.string   "registeredFirst",       :limit => 1
    t.string   "isOnsite",              :limit => 1
    t.integer  "spouseID"
    t.integer  "newPersonID"
  end

  create_table "engine_schema_info", :id => false, :force => true do |t|
    t.string  "engine_name"
    t.integer "version"
  end

# Could not dump table "fsk_allocations" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102546138>

  create_table "fsk_fields", :force => true do |t|
    t.string "name", :limit => 50
  end

# Could not dump table "fsk_fields_roles" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102506088>

  create_table "fsk_kit_categories", :force => true do |t|
    t.string   "name",         :limit => 50,                  :null => false
    t.string   "description",  :limit => 2000
    t.integer  "lock_version",                 :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "fsk_line_items" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001024a1f70>

# Could not dump table "fsk_orders" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102442228>

# Could not dump table "fsk_products" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001023debd8>

  create_table "fsk_roles", :force => true do |t|
    t.string "name", :limit => 50
  end

# Could not dump table "fsk_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102305220>

# Could not dump table "hr_ms_payment" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102227c40>

# Could not dump table "hr_review360_review360" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101673bd8>

# Could not dump table "hr_review360_review360light" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015dc148>

  create_table "hr_review360_reviewsession", :primary_key => "ReviewSessionID", :force => true do |t|
    t.string   "name",            :limit => 80
    t.string   "purpose"
    t.datetime "dateDue"
    t.datetime "dateStarted"
    t.string   "revieweeID",      :limit => 128
    t.string   "administratorID", :limit => 128
    t.string   "requestedByID",   :limit => 128
  end

  create_table "hr_review360_reviewsessionlight", :primary_key => "ReviewSessionLightID", :force => true do |t|
    t.string   "name",            :limit => 80
    t.string   "purpose"
    t.datetime "dateDue"
    t.datetime "dateStarted"
    t.string   "revieweeID",      :limit => 128
    t.string   "administratorID", :limit => 128
    t.string   "requestedByID",   :limit => 128
  end

# Could not dump table "hr_si_application_2003_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104d90a58>

# Could not dump table "hr_si_application_2004_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104b21880>

# Could not dump table "hr_si_application_2005_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102f81b70>

# Could not dump table "hr_si_application_2006_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e610b0>

# Could not dump table "hr_si_applications" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d4a0f0>

# Could not dump table "hr_si_payment" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d2edf0>

  create_table "hr_si_project", :primary_key => "SIProjectID", :force => true do |t|
    t.string   "name"
    t.string   "partnershipRegion",             :limit => 50
    t.string   "history",                       :limit => 8000
    t.string   "city"
    t.string   "country"
    t.string   "details",                       :limit => 8000
    t.string   "status"
    t.string   "destinationGatewayCity"
    t.datetime "departDateFromGateCity"
    t.datetime "arrivalDateAtLocation"
    t.string   "locationGatewayCity"
    t.datetime "departDateFromLocation"
    t.datetime "arrivalDateAtGatewayCity"
    t.integer  "flightBudget"
    t.string   "gatewayCitytoLocationFlightNo"
    t.string   "locationToGatewayCityFlightNo"
    t.string   "inCountryContact"
    t.string   "scholarshipAccountNo"
    t.string   "operatingAccountNo"
    t.string   "AOA"
    t.string   "MPTA"
    t.integer  "staffCost"
    t.integer  "studentCost"
    t.text     "studentCostExplaination"
    t.boolean  "insuranceFormsReceived"
    t.boolean  "CAPSFeePaid"
    t.boolean  "adminFeePaid"
    t.string   "storiesXX"
    t.string   "stats"
    t.boolean  "secure"
    t.boolean  "projEvalCompleted"
    t.integer  "evangelisticExposures"
    t.integer  "receivedChrist"
    t.integer  "jesusFilmExposures"
    t.integer  "jesusFilmReveivedChrist"
    t.integer  "coverageActivitiesExposures"
    t.integer  "coverageActivitiesDecisions"
    t.integer  "holySpiritDecisions"
    t.string   "website"
    t.string   "destinationAddress"
    t.string   "destinationPhone"
    t.string   "siYear"
    t.integer  "fk_isCoord"
    t.integer  "fk_isAPD"
    t.integer  "fk_isPD"
    t.string   "projectType",                   :limit => 1
    t.datetime "studentStartDate"
    t.datetime "studentEndDate"
    t.datetime "staffStartDate"
    t.datetime "staffEndDate"
    t.datetime "leadershipStartDate"
    t.datetime "leadershipEndDate"
    t.datetime "createDate"
    t.binary   "lastChangedDate",               :limit => 8
    t.integer  "lastChangedBy"
    t.string   "displayLocation"
    t.boolean  "partnershipRegionOnly"
    t.integer  "internCost"
    t.boolean  "onHold"
    t.integer  "maxNoStaffPMale"
    t.integer  "maxNoStaffPFemale"
    t.integer  "maxNoStaffPCouples"
    t.integer  "maxNoStaffPFamilies"
    t.integer  "maxNoStaffP"
    t.integer  "maxNoInternAMale"
    t.integer  "maxNoInternAFemale"
    t.integer  "maxNoInternACouples"
    t.integer  "maxNoInternAFamilies"
    t.integer  "maxNoInternA"
    t.integer  "maxNoInternPMale"
    t.integer  "maxNoInternPFemale"
    t.integer  "maxNoInternPCouples"
    t.integer  "maxNoInternPFamilies"
    t.integer  "maxNoInternP"
    t.integer  "maxNoStudentAMale"
    t.integer  "maxNoStudentAFemale"
    t.integer  "maxNoStudentACouples"
    t.integer  "maxNoStudentAFamilies"
    t.integer  "maxNoStudentA"
    t.integer  "maxNoStudentPMale"
    t.integer  "maxNoStudentPFemale"
    t.integer  "maxNoStudentPCouples"
    t.integer  "maxNoStudentPFamilies"
    t.integer  "maxNoStudentP"
  end

# Could not dump table "hr_si_reference" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b6cd78>

# Could not dump table "hr_si_reference_2003_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001029990c8>

# Could not dump table "hr_si_reference_2004_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010265b898>

# Could not dump table "hr_si_reference_2005_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102296758>

# Could not dump table "hr_si_reference_2006_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015bde78>

# Could not dump table "hr_si_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015b8720>

  create_table "lat_long_by_zip_code", :force => true do |t|
    t.string  "zip"
    t.decimal "lat",  :precision => 15, :scale => 10
    t.decimal "long", :precision => 15, :scale => 10
  end

  create_table "linczone_contacts", :primary_key => "ContactID", :force => true do |t|
    t.timestamp "EntryDate"
    t.string    "FirstName",            :limit => 120
    t.string    "LastName",             :limit => 120
    t.string    "HomeAddress",          :limit => 200
    t.string    "City",                 :limit => 20
    t.string    "State",                :limit => 20
    t.string    "Zip",                  :limit => 80
    t.string    "Email",                :limit => 120
    t.string    "HighSchool",           :limit => 120
    t.string    "CampusName",           :limit => 200
    t.string    "CampusID",             :limit => 80
    t.string    "ReferrerFirstName",    :limit => 120
    t.string    "ReferrerLastName",     :limit => 120
    t.string    "ReferrerRelationship", :limit => 100
    t.string    "ReferrerEmail",        :limit => 200
    t.string    "InfoCCC",              :limit => 1,   :default => "F"
    t.string    "InfoNav",              :limit => 1,   :default => "F"
    t.string    "InfoIV",               :limit => 1,   :default => "F"
    t.string    "InfoFCA",              :limit => 1,   :default => "F"
    t.string    "InfoBSU",              :limit => 1,   :default => "F"
    t.string    "InfoCACM",             :limit => 1,   :default => "F"
    t.string    "InfoEFCA",             :limit => 1,   :default => "F"
    t.string    "InfoGCM",              :limit => 1,   :default => "F"
    t.string    "InfoWesley",           :limit => 1,   :default => "F"
  end

  create_table "mail_delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "mail_groups" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101583520>

# Could not dump table "mail_members" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010157af88>

  create_table "mail_owners", :force => true do |t|
    t.integer  "group_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "exception",  :default => false
  end

  create_table "mail_users", :force => true do |t|
    t.string   "guid"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "designation"
    t.string   "employee_id"
    t.boolean  "admin",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ministries", :force => true do |t|
    t.string "name"
  end

# Could not dump table "ministry_activity" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014f15a8>

# Could not dump table "ministry_activity_history" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014e74e0>

  create_table "ministry_address", :primary_key => "AddressID", :force => true do |t|
    t.datetime "startdate"
    t.datetime "enddate"
    t.string   "address1",  :limit => 60
    t.string   "address2",  :limit => 60
    t.string   "address3",  :limit => 60
    t.string   "address4",  :limit => 60
    t.string   "city",      :limit => 35
    t.string   "state",     :limit => 6
    t.string   "zip",       :limit => 10
    t.string   "country",   :limit => 64
  end

  create_table "ministry_assoc_activitycontact", :id => false, :force => true do |t|
    t.integer "ActivityID",                                 :null => false
    t.string  "accountNo",  :limit => 11,                   :null => false
    t.boolean "dbioDummy",                :default => true, :null => false
  end

  create_table "ministry_assoc_dependents", :id => false, :force => true do |t|
    t.integer "DependentID",                                 :null => false
    t.string  "accountNo",   :limit => 11,                   :null => false
    t.boolean "dbioDummy",                 :default => true, :null => false
  end

  create_table "ministry_assoc_otherministries", :id => false, :force => true do |t|
    t.string  "NonCccMinID",  :limit => 64,                   :null => false
    t.string  "TargetAreaID", :limit => 64,                   :null => false
    t.boolean "dbioDummy",                  :default => true, :null => false
  end

# Could not dump table "ministry_authorization" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014c03b8>

# Could not dump table "ministry_changerequest" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014b6750>

  create_table "ministry_dependent", :primary_key => "DependentID", :force => true do |t|
    t.string   "firstName",  :limit => 80
    t.string   "middleName", :limit => 80
    t.string   "lastName",   :limit => 80
    t.datetime "birthdate"
    t.string   "gender",     :limit => 1
  end

  create_table "ministry_fieldchange", :primary_key => "FieldChangeID", :force => true do |t|
    t.string  "field",              :limit => 30
    t.string  "oldValue"
    t.string  "newValue"
    t.integer "Fk_hasFieldChanges"
  end

  create_table "ministry_involvement", :primary_key => "involvementID", :force => true do |t|
    t.integer "fk_PersonID"
    t.integer "fk_StrategyID"
  end

  create_table "ministry_locallevel", :primary_key => "teamID", :force => true do |t|
    t.string   "name",                   :limit => 100
    t.string   "lane",                   :limit => 10
    t.string   "note"
    t.string   "region",                 :limit => 2
    t.string   "address1",               :limit => 35
    t.string   "address2",               :limit => 35
    t.string   "city",                   :limit => 30
    t.string   "state",                  :limit => 6
    t.string   "zip",                    :limit => 10
    t.string   "country",                :limit => 64
    t.string   "phone",                  :limit => 24
    t.string   "fax",                    :limit => 24
    t.string   "email",                  :limit => 50
    t.string   "url"
    t.string   "isActive",               :limit => 1
    t.datetime "startdate"
    t.datetime "stopdate"
    t.string   "Fk_OrgRel",              :limit => 64
    t.string   "no",                     :limit => 2
    t.string   "abbrv",                  :limit => 2
    t.string   "hasMultiRegionalAccess"
    t.string   "dept_id"
  end

  create_table "ministry_missional_team_member", :force => true do |t|
    t.integer "personID"
    t.integer "teamID"
    t.boolean "is_people_soft"
    t.boolean "is_leader"
  end

# Could not dump table "ministry_movement_contact" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101488f58>

# Could not dump table "ministry_newaddress" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101410ff8>

# Could not dump table "ministry_newaddress_restore" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001013f5690>

  create_table "ministry_noncccmin", :primary_key => "NonCccMinID", :force => true do |t|
    t.string "ministry",    :limit => 50
    t.string "firstName",   :limit => 30
    t.string "lastName",    :limit => 30
    t.string "address1",    :limit => 35
    t.string "address2",    :limit => 35
    t.string "city",        :limit => 30
    t.string "state",       :limit => 6
    t.string "zip",         :limit => 10
    t.string "country",     :limit => 64
    t.string "homePhone",   :limit => 24
    t.string "workPhone",   :limit => 24
    t.string "mobilePhone", :limit => 24
    t.string "email",       :limit => 80
    t.string "url",         :limit => 50
    t.string "pager",       :limit => 24
    t.string "fax",         :limit => 24
    t.string "note"
  end

  create_table "ministry_note", :primary_key => "NoteID", :force => true do |t|
    t.datetime "dateEntered"
    t.string   "title",                :limit => 80
    t.text     "note"
    t.string   "Fk_loaNote",           :limit => 64
    t.string   "Fk_resignationLetter", :limit => 64
    t.string   "Fk_authorizationNote", :limit => 64
  end

# Could not dump table "ministry_person" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101266b80>

# Could not dump table "ministry_regionalstat" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101234a68>

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

# Could not dump table "ministry_staff" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000100fad178>

  create_table "ministry_staffchangerequest", :primary_key => "ChangeRequestID", :force => true do |t|
    t.string "updateStaff", :limit => 64
  end

# Could not dump table "ministry_statistic" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000100f91f68>

  create_table "ministry_strategy", :primary_key => "strategyID", :force => true do |t|
    t.string "name"
    t.string "abreviation"
  end

# Could not dump table "ministry_targetarea" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000100f67650>

# Could not dump table "ministry_targetarea_2009" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010629eaa8>

  create_table "ministry_viewactivitycontacts", :id => false, :force => true do |t|
    t.string   "accountNo",                :limit => 11,                    :null => false
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
    t.string   "spouseFirstName",          :limit => 22
    t.string   "spouseMiddleName",         :limit => 15
    t.string   "spouseLastName",           :limit => 30
    t.string   "spouseAccountNo",          :limit => 11
    t.string   "spouseEmail",              :limit => 50
    t.string   "fianceeFirstName",         :limit => 15
    t.string   "fianceeMiddleName",        :limit => 15
    t.string   "fianceeLastName",          :limit => 30
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
    t.integer  "ActivityID",                                                :null => false
    t.string   "fianceeAccountno",         :limit => 11
    t.string   "removedFromPeopleSoft",    :limit => 1,    :default => "N"
    t.string   "isNonUSStaff",             :limit => 1
    t.string   "primaryEmpLocDesc",        :limit => 128
    t.integer  "person_id"
  end

  create_table "ministry_viewdependentsstaff", :id => false, :force => true do |t|
    t.string   "accountNo",                :limit => 11,                    :null => false
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
    t.string   "spouseFirstName",          :limit => 22
    t.string   "spouseMiddleName",         :limit => 15
    t.string   "spouseLastName",           :limit => 30
    t.string   "spouseAccountNo",          :limit => 11
    t.string   "spouseEmail",              :limit => 50
    t.string   "fianceeFirstName",         :limit => 15
    t.string   "fianceeMiddleName",        :limit => 15
    t.string   "fianceeLastName",          :limit => 30
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
    t.integer  "DependentID",                                               :null => false
    t.string   "fianceeAccountno",         :limit => 11
    t.string   "removedFromPeopleSoft",    :limit => 1,    :default => "N"
    t.string   "primaryEmpLocDesc",        :limit => 128
  end

  create_table "ministry_viewnoncccmintargetarea", :id => false, :force => true do |t|
    t.string  "NonCccMinID",       :limit => 64,                 :null => false
    t.integer "TargetAreaID",                     :default => 0, :null => false
    t.string  "name",              :limit => 100
    t.string  "address1",          :limit => 35
    t.string  "address2",          :limit => 35
    t.string  "city",              :limit => 30
    t.string  "state",             :limit => 32
    t.string  "zip",               :limit => 10
    t.string  "country",           :limit => 64
    t.string  "phone",             :limit => 24
    t.string  "fax",               :limit => 24
    t.string  "email",             :limit => 50
    t.string  "url"
    t.string  "abbrv",             :limit => 32
    t.string  "fice",              :limit => 32
    t.string  "note"
    t.string  "altName",           :limit => 100
    t.string  "isSecure",          :limit => 1
    t.string  "isClosed",          :limit => 1
    t.string  "region",            :limit => 2
    t.string  "mpta",              :limit => 30
    t.string  "urlToLogo"
    t.string  "enrollment",        :limit => 10
    t.string  "monthSchoolStarts", :limit => 10
    t.string  "monthSchoolStops",  :limit => 10
    t.string  "isSemester",        :limit => 1
    t.string  "isApproved",        :limit => 1
    t.string  "aoaPriority",       :limit => 10
    t.string  "aoa",               :limit => 100
    t.string  "ciaUrl"
    t.string  "infoUrl"
  end

  create_table "ministry_viewsortedactivities", :id => false, :force => true do |t|
    t.string   "name",            :limit => 100
    t.string   "url"
    t.string   "facebook"
    t.integer  "ActivityID",                     :default => 0, :null => false
    t.string   "status",          :limit => 2
    t.datetime "periodBegin"
    t.string   "strategy",        :limit => 2
    t.string   "transUsername",   :limit => 50
    t.integer  "fk_teamID"
    t.integer  "fk_targetAreaID"
  end

  create_table "ministry_viewstaffdependents", :id => false, :force => true do |t|
    t.integer  "DependentID",               :default => 0, :null => false
    t.string   "firstName",   :limit => 80
    t.string   "middleName",  :limit => 80
    t.string   "lastName",    :limit => 80
    t.datetime "birthdate"
    t.string   "gender",      :limit => 1
    t.string   "accountNo",   :limit => 11,                :null => false
  end

  create_table "ministry_viewtargetareanoncccmin", :id => false, :force => true do |t|
    t.integer "NonCccMinID",                :default => 0, :null => false
    t.string  "ministry",     :limit => 50
    t.string  "firstName",    :limit => 30
    t.string  "lastName",     :limit => 30
    t.string  "address1",     :limit => 35
    t.string  "address2",     :limit => 35
    t.string  "city",         :limit => 30
    t.string  "state",        :limit => 6
    t.string  "zip",          :limit => 10
    t.string  "country",      :limit => 64
    t.string  "homePhone",    :limit => 24
    t.string  "workPhone",    :limit => 24
    t.string  "mobilePhone",  :limit => 24
    t.string  "email",        :limit => 80
    t.string  "url",          :limit => 50
    t.string  "pager",        :limit => 24
    t.string  "fax",          :limit => 24
    t.string  "note"
    t.string  "TargetAreaID", :limit => 64,                :null => false
  end

# Could not dump table "mpd_contact_actions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104b9bc20>

# Could not dump table "mpd_contacts" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104b62128>

# Could not dump table "mpd_events" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104b4eb00>

  create_table "mpd_expense_types", :force => true do |t|
    t.string "name",                            :null => false
    t.float  "default_amount", :default => 0.0
  end

# Could not dump table "mpd_expenses" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104b3c0e0>

# Could not dump table "mpd_letter_images" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104b29030>

  create_table "mpd_letter_templates", :force => true do |t|
    t.string  "name",                                 :null => false
    t.string  "thumbnail_filename",   :default => ""
    t.string  "pdf_preview_filename", :default => ""
    t.text    "description"
    t.integer "number_of_images",     :default => 0
  end

# Could not dump table "mpd_letters" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104af57a8>

# Could not dump table "mpd_priorities" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104ae6208>

  create_table "mpd_roles", :force => true do |t|
    t.string "name"
  end

# Could not dump table "mpd_roles_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104ad4b48>

# Could not dump table "mpd_sessions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104ac9450>

# Could not dump table "mpd_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104aab4f0>

  create_table "nag_users", :force => true do |t|
    t.integer  "ssm_id",                    :null => false
    t.datetime "last_login"
    t.datetime "created_at"
    t.integer  "created_by", :default => 0
    t.datetime "updated_at"
    t.integer  "updated_by"
  end

  create_table "nags", :force => true do |t|
    t.text   "query"
    t.string "email"
    t.string "subject"
    t.text   "body"
    t.string "emailfield"
    t.text   "userbody"
    t.text   "usersubject"
    t.string "period"
  end

# Could not dump table "old_wsn_sp_wsnapplication" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e99550>

  create_table "oncampus_orders", :force => true do |t|
    t.integer  "person_id"
    t.string   "purpose",                    :limit => 100,                          :null => false
    t.string   "payment",                    :limit => 100,                          :null => false
    t.boolean  "format_dvd",                                :default => true,        :null => false
    t.boolean  "format_quicktime",                          :default => false,       :null => false
    t.boolean  "format_flash",                              :default => false,       :null => false
    t.string   "campus",                     :limit => 100,                          :null => false
    t.string   "campus_state",               :limit => 50,                           :null => false
    t.string   "commercial_movement_name",   :limit => 200,                          :null => false
    t.string   "commercial_school_name",     :limit => 200
    t.text     "commercial_additional_info"
    t.boolean  "user_agreement",                            :default => false,       :null => false
    t.string   "status",                     :limit => 20,  :default => "submitted", :null => false
    t.datetime "created_at",                                                         :null => false
    t.string   "commercial_website",         :limit => 300
    t.boolean  "commercial_logo",                           :default => true
    t.string   "color",                      :limit => 20,  :default => "#FFFFFF"
    t.datetime "produced_at"
    t.datetime "shipped_at"
  end

  create_table "oncampus_uses", :force => true do |t|
    t.integer  "order_id",                                             :null => false
    t.string   "type",               :limit => 20,                     :null => false
    t.string   "context",            :limit => 20,                     :null => false
    t.string   "title",              :limit => 150,                    :null => false
    t.datetime "date_start"
    t.datetime "date_end"
    t.boolean  "single_event",                      :default => false, :null => false
    t.boolean  "commercial_frisbee",                :default => false, :null => false
    t.boolean  "commercial_ramen",                  :default => false, :null => false
    t.text     "description",                                          :null => false
    t.text     "feedback",                                             :null => false
  end

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

# Could not dump table "profile_pictures" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e47930>

  create_table "questionnaires", :force => true do |t|
    t.string   "title",      :limit => 200
    t.string   "type",       :limit => 50
    t.datetime "created_at"
  end

  create_table "rails_crons", :force => true do |t|
    t.text    "command"
    t.integer "start"
    t.integer "finish"
    t.integer "every"
    t.boolean "concurrent"
  end

  create_table "rideshare_event", :force => true do |t|
    t.integer "conference_id"
    t.string  "event_name",    :limit => 50
    t.string  "password",      :limit => 50, :null => false
    t.text    "email_content"
  end

# Could not dump table "rideshare_ride" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102e07268>

  create_table "school_years", :force => true do |t|
    t.string   "name"
    t.string   "level"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "si_answer_sheets" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102df3f88>

# Could not dump table "si_answers" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102ddbb18>

# Could not dump table "si_applies" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102dcd4a0>

# Could not dump table "si_apply_sheets" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102dc1dd0>

# Could not dump table "si_character_references" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102da71b0>

# Could not dump table "si_conditions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d9e510>

# Could not dump table "si_elements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d6adc8>

  create_table "si_email_templates", :force => true do |t|
    t.string  "name",    :limit => 60, :null => false
    t.text    "content"
    t.boolean "enabled"
    t.string  "subject"
  end

# Could not dump table "si_pages" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d516c0>

# Could not dump table "si_payments" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d40820>

  create_table "si_question_sheets", :force => true do |t|
    t.string "label", :limit => 60, :null => false
  end

  create_table "si_roles", :force => true do |t|
    t.string "role",       :null => false
    t.string "user_class", :null => false
  end

  create_table "si_sleeve_sheets", :force => true do |t|
    t.integer "sleeve_id",                       :null => false
    t.integer "question_sheet_id",               :null => false
    t.string  "title",             :limit => 60, :null => false
    t.string  "assign_to",         :limit => 36, :null => false
  end

# Could not dump table "si_sleeves" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d21c90>

# Could not dump table "si_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102d157d8>

# Could not dump table "simplesecuritymanager_user" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102cf31d8>

# Could not dump table "sitrack_application_all_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b60820>

# Could not dump table "sitrack_children" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b51f50>

  create_table "sitrack_columns", :force => true do |t|
    t.string   "name",              :limit => 30,                  :null => false
    t.string   "column_type",       :limit => 20,                  :null => false
    t.string   "select_clause",     :limit => 7000,                :null => false
    t.string   "where_clause"
    t.string   "update_clause",     :limit => 2000
    t.string   "table_clause",      :limit => 100
    t.integer  "show_in_directory", :limit => 1,    :default => 1, :null => false
    t.integer  "writeable",         :limit => 1,    :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "maxlength"
  end

# Could not dump table "sitrack_enum_values" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b25d60>

# Could not dump table "sitrack_feeds" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102b12198>

  create_table "sitrack_forms", :force => true do |t|
    t.integer  "approver_id",                                     :null => false
    t.string   "type",                            :limit => 50,   :null => false
    t.integer  "current_years_salary"
    t.integer  "previous_years_salary"
    t.integer  "additional_salary"
    t.integer  "adoption"
    t.integer  "counseling"
    t.integer  "childrens_expenses"
    t.integer  "college"
    t.integer  "private_school"
    t.integer  "graduate_studies"
    t.integer  "auto_purchase"
    t.integer  "settling_in_expenses"
    t.integer  "reimbursable_expenses"
    t.integer  "tax_rate"
    t.datetime "date_of_change"
    t.string   "action"
    t.string   "reopen_as",                       :limit => 100
    t.datetime "freeze_start"
    t.datetime "freeze_end"
    t.string   "change_assignment_from_team",     :limit => 100
    t.string   "change_assignment_from_location", :limit => 100
    t.string   "change_assignment_to_team",       :limit => 100
    t.string   "change_assignment_to_location",   :limit => 100
    t.string   "restint_location",                :limit => 100
    t.string   "departure_date_certainty",        :limit => 100
    t.integer  "hours_per_week"
    t.string   "other_explanation",               :limit => 1000
    t.datetime "new_staff_training_date"
    t.string   "payroll_action",                  :limit => 100
    t.string   "payroll_reason",                  :limit => 100
    t.string   "hrd",                             :limit => 100
    t.string   "spouse_name",                     :limit => 100
    t.boolean  "spouse_transitioning"
    t.string   "salary_reason",                   :limit => 1000
    t.integer  "annual_salary"
    t.integer  "hr_si_application_id",                            :null => false
    t.text     "additional_notes"
  end

# Could not dump table "sitrack_mpd" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102a94e00>

# Could not dump table "sitrack_queries" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001029fd960>

# Could not dump table "sitrack_saved_criteria" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102994410>

# Could not dump table "sitrack_session_values" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001028ca368>

# Could not dump table "sitrack_sessions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001027f1c98>

# Could not dump table "sitrack_tracking" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001027018d8>

# Could not dump table "sitrack_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001026e8658>

# Could not dump table "sitrack_view_columns" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001026d4540>

# Could not dump table "sitrack_views" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001026bf078>

# Could not dump table "sn_campus_involvements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010265d620>

  create_table "sn_columns", :force => true do |t|
    t.string   "title"
    t.string   "update_clause"
    t.string   "from_clause"
    t.text     "select_clause"
    t.string   "column_type"
    t.string   "writeable"
    t.string   "join_clause"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_model"
    t.string   "source_column"
    t.string   "foreign_key"
  end

  create_table "sn_correspondence_types", :force => true do |t|
    t.string  "name"
    t.integer "overdue_lifespan"
    t.integer "expiry_lifespan"
    t.string  "actions_now_task"
    t.string  "actions_overdue_task"
    t.string  "actions_followup_task"
    t.text    "redirect_params"
    t.string  "redirect_target_id_type"
  end

# Could not dump table "sn_correspondences" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102527d28>

# Could not dump table "sn_custom_attributes" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001024e5680>

# Could not dump table "sn_custom_values" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001024c68c0>

  create_table "sn_delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sn_dorms" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010247ce28>

  create_table "sn_email_templates", :force => true do |t|
    t.integer  "correspondence_type_id"
    t.string   "outcome_type"
    t.string   "subject",                :null => false
    t.string   "from",                   :null => false
    t.string   "bcc"
    t.string   "cc"
    t.text     "body",                   :null => false
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sn_emails", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.text     "people_ids"
    t.text     "missing_address_ids"
    t.integer  "search_id"
    t.integer  "sender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sn_free_times", :force => true do |t|
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "day_of_week"
    t.integer  "timetable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "css_class"
    t.decimal  "weight",       :precision => 4, :scale => 2
  end

# Could not dump table "sn_group_involvements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010234a0c8>

  create_table "sn_group_types", :force => true do |t|
    t.integer  "ministry_id"
    t.string   "group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mentor_priority"
    t.boolean  "public"
    t.integer  "unsuitability_leader"
    t.integer  "unsuitability_coleader"
    t.integer  "unsuitability_participant"
  end

# Could not dump table "sn_groups" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001021fb7a8>

  create_table "sn_imports", :force => true do |t|
    t.integer  "person_id"
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "height"
    t.integer  "width"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sn_involvement_histories", :force => true do |t|
    t.string   "type"
    t.integer  "person_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "campus_id"
    t.integer  "school_year_id"
    t.integer  "ministry_id"
    t.integer  "ministry_role_id"
    t.integer  "campus_involvement_id"
    t.integer  "ministry_involvement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sn_ministries" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010207d5c0>

# Could not dump table "sn_ministry_campuses" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001020265b8>

# Could not dump table "sn_ministry_involvements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010166dfd0>

  create_table "sn_ministry_role_permissions", :force => true do |t|
    t.integer "permission_id"
    t.integer "ministry_role_id"
    t.string  "created_at"
  end

# Could not dump table "sn_ministry_roles" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015dcb48>

  create_table "sn_permissions", :force => true do |t|
    t.string "description"
    t.string "controller"
    t.string "action"
  end

  create_table "sn_searches", :force => true do |t|
    t.integer  "person_id"
    t.text     "options"
    t.text     "query"
    t.text     "tables"
    t.boolean  "saved"
    t.string   "name"
    t.string   "order"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sn_sessions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015c6410>

# Could not dump table "sn_timetables" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015c0ab0>

# Could not dump table "sn_training_answers" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015b9580>

# Could not dump table "sn_training_categories" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015b1d58>

  create_table "sn_training_question_activations", :force => true do |t|
    t.integer  "ministry_id"
    t.integer  "training_question_id"
    t.boolean  "mandate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sn_training_questions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015a53a0>

  create_table "sn_user_group_permissions", :force => true do |t|
    t.integer "permission_id"
    t.integer "user_group_id"
    t.string  "created_at"
  end

  create_table "sn_user_groups", :force => true do |t|
    t.string  "name"
    t.date    "created_at"
    t.integer "ministry_id"
  end

  create_table "sn_user_memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "user_group_id"
    t.date    "created_at"
  end

# Could not dump table "sn_view_columns" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010158db10>

# Could not dump table "sn_views" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001015855f0>

# Could not dump table "sp_answer_sheet_question_sheets" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010157e048>

  create_table "sp_answer_sheets", :force => true do |t|
    t.integer  "question_sheet_id", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "completed_at"
  end

# Could not dump table "sp_answers" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010154bd50>

# Could not dump table "sp_answers_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101543f10>

  create_table "sp_application_moves", :force => true do |t|
    t.integer  "application_id"
    t.integer  "old_project_id"
    t.integer  "new_project_id"
    t.integer  "moved_by_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sp_applications" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014e0280>

  create_table "sp_conditions", :force => true do |t|
    t.integer "question_sheet_id", :null => false
    t.integer "trigger_id",        :null => false
    t.string  "expression",        :null => false
    t.integer "toggle_page_id",    :null => false
    t.integer "toggle_id"
  end

# Could not dump table "sp_donations" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014d4480>

# Could not dump table "sp_elements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014b9248>

  create_table "sp_elements_deprecated", :force => true do |t|
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

# Could not dump table "sp_email_templates" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001014a2368>

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

# Could not dump table "sp_page_elements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010147ced8>

  create_table "sp_page_elements_deprecated", :force => true do |t|
    t.integer  "page_id"
    t.integer  "element_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sp_pages" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000101418528>

  create_table "sp_pages_deprecated", :force => true do |t|
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

# Could not dump table "sp_project_versions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010127fb80>

# Could not dump table "sp_projects" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000100fdfd58>

  create_table "sp_question_options", :force => true do |t|
    t.integer  "question_id"
    t.string   "option",      :limit => 50
    t.string   "value",       :limit => 50
    t.integer  "position"
    t.datetime "created_at"
  end

  create_table "sp_question_sheets", :force => true do |t|
    t.string  "label",    :limit => 60,                    :null => false
    t.boolean "archived",               :default => false
  end

  create_table "sp_questionnaire_pages", :force => true do |t|
    t.integer  "questionnaire_id"
    t.integer  "page_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sp_references", :force => true do |t|
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
    t.boolean  "is_staff",                  :default => false
  end

# Could not dump table "sp_references_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010627cd40>

  create_table "sp_roles", :force => true do |t|
    t.string "role",       :limit => 50
    t.string "user_class"
  end

# Could not dump table "sp_staff" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000106270ec8>

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

# Could not dump table "sp_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010623b4a8>

# Could not dump table "staffsite_staffsitepref" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010621d8b8>

# Could not dump table "staffsite_staffsiteprofile" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010607a8a8>

  create_table "states", :force => true do |t|
    t.string "state", :limit => 100
    t.string "code",  :limit => 10
  end

  create_table "summer_placement_preferences", :force => true do |t|
    t.integer  "person_id"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "versions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000106039c90>

# Could not dump table "wsn_sp_answer_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010602a0d8>

# Could not dump table "wsn_sp_question_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001060172d0>

  create_table "wsn_sp_questiontext_deprecated", :primary_key => "questionTextID", :force => true do |t|
    t.string "body",       :limit => 250
    t.string "answerType", :limit => 50
    t.string "status",     :limit => 50
  end

# Could not dump table "wsn_sp_reference_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104d6cb58>

# Could not dump table "wsn_sp_wsnapplication_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104aeb9b0>

# Could not dump table "wsn_sp_wsndonations_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104addb30>

# Could not dump table "wsn_sp_wsnevaluation_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000104ab0b30>

# Could not dump table "wsn_sp_wsnproject_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102f8e5a0>

# Could not dump table "wsn_sp_wsnusers_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000102f87c00>

end
