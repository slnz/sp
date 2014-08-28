Fe::Person.class_eval do
  self.table_name = "ministry_person"
  has_many   :applications
end
