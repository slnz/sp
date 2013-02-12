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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130128160757) do

  create_table "academic_departments", :force => true do |t|
    t.string "name"
  end

  create_table "aoas", :force => true do |t|
    t.string "name"
  end

  add_index "aoas", ["name"], :name => "name", :unique => true

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "authentications", ["uid", "provider"], :name => "uid_provider", :unique => true

  create_table "cms_assoc_filecategory", :id => false, :force => true do |t|
    t.string  "CmsFileID",     :limit => 64,                   :null => false
    t.string  "CmsCategoryID", :limit => 64,                   :null => false
    t.boolean "dbioDummy",                   :default => true
  end

  create_table "cms_cmscategory", :primary_key => "CmsCategoryID", :force => true do |t|
    t.integer "parentCategory"
    t.string  "catName",        :limit => 256
    t.string  "catDesc",        :limit => 2000
    t.string  "path",           :limit => 2000
    t.string  "pathid",         :limit => 2000
  end

  add_index "cms_cmscategory", ["parentCategory"], :name => "index1"

  create_table "cms_cmsfile", :primary_key => "CmsFileID", :force => true do |t|
    t.string   "mime",         :limit => 128
    t.string   "title",        :limit => 256
    t.integer  "accessCount"
    t.datetime "dateAdded"
    t.datetime "dateModified"
    t.string   "moderatedYet", :limit => 1
    t.text     "summary"
    t.string   "quality",      :limit => 256
    t.datetime "expDate"
    t.datetime "lastAccessed"
    t.string   "modMsg",       :limit => 4000
    t.string   "keywords",     :limit => 4000
    t.string   "url",          :limit => 128
    t.string   "detail",       :limit => 4000
    t.string   "language",     :limit => 128
    t.string   "version",      :limit => 128
    t.string   "author",       :limit => 256
    t.string   "submitter",    :limit => 256
    t.string   "contact",      :limit => 256
    t.integer  "rating"
  end

  add_index "cms_cmsfile", ["accessCount"], :name => "index1"

  create_table "cms_viewcategoryidfiles", :id => false, :force => true do |t|
    t.integer  "CmsFileID",                     :default => 0, :null => false
    t.string   "mime",          :limit => 128
    t.string   "title",         :limit => 256
    t.integer  "accessCount"
    t.datetime "dateAdded"
    t.datetime "dateModified"
    t.string   "moderatedYet",  :limit => 1
    t.text     "summary"
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
    t.text     "summary"
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

  create_table "crs2_additional_expenses_item", :force => true do |t|
    t.string   "type",               :limit => 31, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                                          :null => false
    t.integer  "location",                                         :null => false
    t.string   "note"
    t.string   "header"
    t.text     "text"
    t.integer  "expense_id"
    t.integer  "registrant_type_id",                               :null => false
  end

  add_index "crs2_additional_expenses_item", ["expense_id"], :name => "fk_additional_expenses_item_expense_id"
  add_index "crs2_additional_expenses_item", ["registrant_type_id", "expense_id"], :name => "unique_registrant_type_expense", :unique => true
  add_index "crs2_additional_expenses_item", ["registrant_type_id"], :name => "fk_additional_expenses_item_registrant_type_id"

  create_table "crs2_additional_info_item", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                     :null => false
    t.integer  "location",                    :null => false
    t.text     "text"
    t.string   "title",         :limit => 60
    t.integer  "conference_id"
  end

  add_index "crs2_additional_info_item", ["conference_id"], :name => "fk_additional_info_item_conference_id"

  create_table "crs2_answer", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",           :null => false
    t.boolean  "value_boolean"
    t.date     "value_date"
    t.float    "value_double"
    t.integer  "value_int"
    t.string   "value_string"
    t.text     "value_text"
    t.integer  "question_usage_id", :null => false
    t.integer  "registrant_id",     :null => false
  end

  add_index "crs2_answer", ["question_usage_id"], :name => "fk_answer_question_usage_id"
  add_index "crs2_answer", ["registrant_id", "question_usage_id"], :name => "unique_registrant_question_usage", :unique => true
  add_index "crs2_answer", ["registrant_id"], :name => "fk_answer_registrant_id"

  create_table "crs2_conference", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                                    :null => false
    t.boolean  "accept_american_express"
    t.boolean  "accept_discover"
    t.boolean  "accept_master_card"
    t.boolean  "accept_scholarships"
    t.boolean  "accept_visa"
    t.string   "admin_password",             :default => "", :null => false
    t.string   "authnet_api_login_id"
    t.string   "authnet_transaction_key"
    t.date     "begin_date",                                 :null => false
    t.string   "check_payable_to"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "email"
    t.string   "contact_name"
    t.string   "phone"
    t.string   "state"
    t.string   "zip"
    t.text     "description"
    t.date     "end_date",                                   :null => false
    t.string   "ministry_type"
    t.string   "name",                       :default => "", :null => false
    t.boolean  "offer_families_extra_rooms"
    t.string   "power_user_password"
    t.string   "region"
    t.datetime "registration_ends_at",                       :null => false
    t.datetime "registration_starts_at",                     :null => false
    t.string   "status",                     :default => "", :null => false
    t.string   "theme"
    t.integer  "url_base_id"
    t.integer  "creator_id",                                 :null => false
    t.string   "home_page_address"
    t.boolean  "ride_share"
    t.string   "event_address1"
    t.string   "event_address2"
    t.string   "event_city"
    t.string   "event_state"
    t.string   "event_zip"
  end

  add_index "crs2_conference", ["creator_id"], :name => "fk_conference_creator_id"
  add_index "crs2_conference", ["name"], :name => "unique_name", :unique => true
  add_index "crs2_conference", ["url_base_id"], :name => "fk_conference_url_base_id"

  create_table "crs2_configuration", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                        :null => false
    t.boolean  "added_builtin_common_questions"
    t.integer  "default_url_base_id"
  end

  add_index "crs2_configuration", ["default_url_base_id"], :name => "fk_configuration_default_url_base_id"

  create_table "crs2_custom_questions_item", :force => true do |t|
    t.string   "type",               :limit => 31, :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                                          :null => false
    t.integer  "location",                                         :null => false
    t.text     "text"
    t.boolean  "required"
    t.integer  "registrant_type_id",                               :null => false
    t.integer  "question_id"
  end

  add_index "crs2_custom_questions_item", ["question_id"], :name => "fk_custom_questions_item_question_id"
  add_index "crs2_custom_questions_item", ["registrant_type_id", "question_id"], :name => "unique_registrant_type_question", :unique => true
  add_index "crs2_custom_questions_item", ["registrant_type_id"], :name => "fk_custom_questions_item_registrant_type_id"

  create_table "crs2_custom_stylesheet", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",       :null => false
    t.text     "customcss"
    t.integer  "conference_id", :null => false
  end

  add_index "crs2_custom_stylesheet", ["conference_id"], :name => "fk_custom_stylesheet_conference_id"

  create_table "crs2_email_addresses", :force => true do |t|
    t.string   "email"
    t.integer  "person_id"
    t.boolean  "primary",    :default => false, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "crs2_expense", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",                                                    :null => false
    t.decimal  "cost",                        :precision => 12, :scale => 2
    t.text     "description"
    t.string   "name",          :limit => 60
    t.integer  "conference_id",                                              :null => false
    t.boolean  "disabled"
  end

  add_index "crs2_expense", ["conference_id"], :name => "fk_expense_conference_id"

  create_table "crs2_expense_selection", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",          :null => false
    t.boolean  "selected"
    t.integer  "registrant_id",    :null => false
    t.integer  "expense_usage_id", :null => false
  end

  add_index "crs2_expense_selection", ["expense_usage_id"], :name => "fk_expense_selection_expense_usage_id"
  add_index "crs2_expense_selection", ["registrant_id", "expense_usage_id"], :name => "unique_registrant_expense_usage", :unique => true
  add_index "crs2_expense_selection", ["registrant_id"], :name => "fk_expense_selection_registrant_id"

  create_table "crs2_module_usage", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",       :null => false
    t.string   "name"
    t.integer  "conference_id"
  end

  add_index "crs2_module_usage", ["conference_id"], :name => "fk_module_usage_conference_id"

