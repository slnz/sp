module Questionnaire
  # prefix for database tables
  mattr_accessor :table_name_prefix
  self.table_name_prefix = 'sp_'
  
  mattr_accessor :answer_sheet_class
  self.answer_sheet_class = 'SpApplication'
  
  mattr_accessor :from_email
  self.from_email = 'info@example.com'
  
end