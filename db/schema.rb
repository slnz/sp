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

ActiveRecord::Schema.define(:version => 20101031193907) do

  create_table "academic_departments", :force => true do |t|
    t.string "name"
  end

  create_table "am_friends_people_deprecated", :id => false, :force => true do |t|
    t.integer "friend_id", :null => false
    t.integer "person_id", :null => false
  end

# Could not dump table "am_group_links_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105bb36a8>

# Could not dump table "am_group_messages_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105ba99a0>

# Could not dump table "am_groups_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105b9a4a0>

  create_table "am_groups_people_deprecated", :id => false, :force => true do |t|
    t.integer  "person_id",  :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_on"
  end

# Could not dump table "am_personal_links_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105b7e0e8>

  create_table "aoas", :force => true do |t|
    t.string "name"
  end

# Could not dump table "ap_signup_deprecated" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105b6dc48>

# Could not dump table "authentications" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105b63018>

  create_table "cms_assoc_filecategory", :id => false, :force => true do |t|
    t.string  "CmsFileID",     :limit => 64,                   :null => false
    t.string  "CmsCategoryID", :limit => 64,                   :null => false
    t.boolean "dbioDummy",                   :default => true
  end

# Could not dump table "cms_cmscategory" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105b49438>

# Could not dump table "cms_cmsfile" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105b2a2e0>

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
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105a563a0>

  create_table "countries", :force => true do |t|
    t.string  "country",  :limit => 100
    t.string  "code",     :limit => 10
    t.boolean "closed",                  :default => false
    t.string  "iso_code"
  end

# Could not dump table "crs2_additional_expenses_item" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105a05d10>

# Could not dump table "crs2_additional_info_item" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001059f0730>

# Could not dump table "crs2_answer" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001059de710>

# Could not dump table "crs2_conference" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010599db20>

# Could not dump table "crs2_configuration" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x00000105990f10>

# Could not dump table "crs2_custom_questions_item" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x0000010597d910>

# Could not dump table "crs2_custom_stylesheet" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001059191e0>

# Could not dump table "crs2_expense" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001059085e8>

# Could not dump table "crs2_expense_selection" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001058f7810>

# Could not dump table "crs2_module_usage" because of following NoMethodError
#   undefined method `type' for #<ActiveRecord::ConnectionAdapters::IndexDefinition:0x000001058e9e40>

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

