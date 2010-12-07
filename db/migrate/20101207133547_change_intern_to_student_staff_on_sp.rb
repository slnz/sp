class ChangeInternToStudentStaffOnSp < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.update("update sp_applications set status = 'accepted_as_student_staff' where status = 'accepted_as_intern'")
    ActiveRecord::Base.connection.update("update sp_elements set style = 'yes-no', object_name = 'application', attribute_name = 'apply_for_leadership', content = '', label = 'Are you applying as a student-staff?' where id = 745")
    ActiveRecord::Base.connection.update("update sp_applications app, sp_answers a set apply_for_leadership = 1 where a.answer_sheet_id = app.id and a.question_id = 745 and apply_for_leadership IS NULL and a.value = 'project intern'")
  end

  def self.down
    ActiveRecord::Base.connection.update("update sp_elements set style = 'drop-down', object_name = '', attribute_name = '', content = 'participant\nstudent-staff', label = 'Are you applying as a...' where id = 745")
    ActiveRecord::Base.connection.update("update sp_applications set status = 'accepted_as_intern' where status = 'accepted_as_student_staff'")
  end
end
