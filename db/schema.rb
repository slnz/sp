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

ActiveRecord::Schema.define(:version => 20101207133547) do

  create_table "aoas", :force => true do |t|
    t.string "name"
  end

# Could not dump table "authentications" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xf0f500>

# Could not dump table "counties" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xeb5460>

  create_table "countries", :force => true do |t|
    t.string  "country",  :limit => 100
    t.string  "code",     :limit => 10
    t.boolean "closed",                  :default => false
    t.string  "iso_code"
  end

  create_table "ministries", :force => true do |t|
    t.string "name"
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

# Could not dump table "ministry_newaddress" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xd96ef8>

# Could not dump table "ministry_person" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xd66564>

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
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xc53168>

# Could not dump table "ministry_targetarea" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xbfdf24>

  create_table "questionnaires", :force => true do |t|
    t.string   "title",      :limit => 200
    t.string   "type",       :limit => 50
    t.datetime "created_at"
  end

# Could not dump table "simplesecuritymanager_user" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xbc6d80>

# Could not dump table "sp_answer_sheet_question_sheets" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xbb56c0>

  create_table "sp_answer_sheets", :force => true do |t|
    t.integer  "question_sheet_id", :null => false
    t.datetime "created_at",        :null => false
    t.datetime "completed_at"
  end

# Could not dump table "sp_answers" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xb94a24>

  create_table "sp_application_moves", :force => true do |t|
    t.integer  "application_id"
    t.integer  "old_project_id"
    t.integer  "new_project_id"
    t.integer  "moved_by_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sp_applications" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0xa25454>

  create_table "sp_conditions", :force => true do |t|
    t.integer "question_sheet_id", :null => false
    t.integer "trigger_id",        :null => false
    t.string  "expression",        :null => false
    t.integer "toggle_page_id",    :null => false
    t.integer "toggle_id"
  end

# Could not dump table "sp_donations" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x94758c>

# Could not dump table "sp_elements" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x835310>

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
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42907bc>

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
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x426da8c>

  create_table "sp_page_elements_deprecated", :force => true do |t|
    t.integer  "page_id"
    t.integer  "element_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sp_pages" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42a1814>

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

# Could not dump table "sp_project_gospel_in_actions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x34af030>

# Could not dump table "sp_project_versions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x3398b10>

# Could not dump table "sp_projects" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x343ceb8>

  create_table "sp_question_options", :force => true do |t|
    t.integer  "question_id"
    t.string   "option",      :limit => 50
    t.string   "value",       :limit => 50
    t.integer  "position"
    t.datetime "created_at"
  end

  create_table "sp_question_sheets", :force => true do |t|
    t.string  "label",    :limit => 1000,                    :null => false
    t.boolean "archived",                 :default => false
  end

  create_table "sp_questionnaire_pages", :force => true do |t|
    t.integer  "questionnaire_id"
    t.integer  "page_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "sp_references" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42c83d8>

# Could not dump table "sp_references_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42c0cdc>

  create_table "sp_roles", :force => true do |t|
    t.string "role",       :limit => 50
    t.string "user_class"
  end

# Could not dump table "sp_staff" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42bbdcc>

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

# Could not dump table "sp_student_quotes" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42b0224>

# Could not dump table "sp_users" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42accf0>

# Could not dump table "versions" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x42a8394>

end
