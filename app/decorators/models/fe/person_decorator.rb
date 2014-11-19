Fe::Person.class_eval do
  self.table_name = "ministry_person"
  has_many   :applications
  has_one    :application, foreign_key: "person_id"
end
