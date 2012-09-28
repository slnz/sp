class Run

  def self.weekly_tasks
    #send_leader_reminder_emails
#    send_stats_reminder_emails -- This is now in the infobase 
    #send_reference_reminder_emails
    #send_app_status_emails
  end
  
  def self.daily_tasks
    # check_apps_for_completion
    SpDonation.update_from_peoplesoft
  end
  
  def self.send_reference_reminder_emails
    SpReference.send_reminders
  end

  def self.send_leader_reminder_emails
    SpProject.send_leader_reminder_emails
  end
  
  def self.send_stats_reminder_emails
    SpProject.send_stats_reminder_emails
  end
  
  def self.send_app_status_emails
    SpApplication.send_status_emails
  end
  
  def self.check_apps_for_completion
    apps_to_check = SpApplication.find_all_by_status("submitted")
    apps_to_check.each do |app|
      app.complete
    end
  end

  #In addition to running this method, change the constant in SpApplication.rb
  def self.change_sp_year
    last_years = SpProject.where(archive_project_date: Date.today)
    last_years.each do |new_project|
      new_project.save(:validate => false)
      new_project.year = Date.today.year + 1
      new_project.start_date = new_project.start_date + 1.year if new_project.start_date
      new_project.end_date = new_project.end_date + 1.year if new_project.end_date
      new_project.date_of_departure = new_project.date_of_departure + 1.year if new_project.date_of_departure
      new_project.date_of_return = new_project.date_of_return + 1.year if new_project.date_of_return
      new_project.apply_by_date = new_project.apply_by_date + 1.year if new_project.apply_by_date
      new_project.pd_start_date = new_project.pd_start_date + 1.year if new_project.pd_start_date
      new_project.pd_end_date = new_project.pd_end_date + 1.year if new_project.pd_end_date
      new_project.pd_close_start_date = new_project.pd_close_start_date + 1.year if new_project.pd_close_start_date
      new_project.pd_close_end_date = new_project.pd_close_end_date + 1.year if new_project.pd_close_end_date
      new_project.student_staff_start_date = new_project.student_staff_start_date + 1.year if new_project.student_staff_start_date
      new_project.student_staff_end_date = new_project.student_staff_end_date + 1.year if new_project.student_staff_end_date
      new_project.staff_start_date = new_project.staff_start_date + 1.year if new_project.staff_start_date
      new_project.staff_end_date = new_project.staff_end_date + 1.year if new_project.staff_end_date
      new_project.archive_project_date = new_project.archive_project_date + 1.year if new_project.archive_project_date
      new_project.open_application_date = new_project.open_application_date + 1.year if new_project.open_application_date
      new_project.current_students_men = 0
      new_project.current_students_women = 0
      new_project.current_applicants_men = 0
      new_project.current_applicants_women = 0
      new_project.save(:validate => false)
    end
    nil
  end
  
  def self.set_version
    projects = SpProject.find_all_by_report_stats_to(nil)
    projects.each do |project|
      project.update_attribute('report_stats_to', 'Campus Ministry - US summer project')
    end
    projects = SpProject.find_all_by_display_location(nil)
    projects.each do |project|
      project.update_attribute('display_location', project.name)
    end
    projects = SpProject.find_all_by_version(nil)
    projects.each do |project|
      project.save!
    end
  end
  
  def self.zero_projects
    projects = SpProject.find_all_by_year_and_project_status("2010", "open")
    projects.each do |project|
      project.current_students_men = 0
      project.current_students_women = 0
      project.current_applicants_men = 0
      project.current_applicants_women = 0
      project.pd_id = nil
      project.apd_id = nil
      project.opd_id = nil
      project.coordinator_id = nil
      project.save!
    end
  end
  
  # Need to fix parent_id's after this
  # def self.create_parent_reference
  #   ref_element = Element.new
  #   ref_element.type = "SpParentReference"
  #   ref_element.text = "Parent Reference (Required if you are in High School)"
  #   ref_element.question_table = "answers"
  #   ref_element.question_column = ""
  #   ref_element.position = 4
  #   ref_element.max_length = 0
  #   ref_element.save!
  #   
  #   ref_pe = PageElement.new
  #   ref_pe.page_id = 16
  #   ref_pe.element_id = ref_element.id
  #   ref_pe.position = 4
  #   ref_pe.save!
  #   
  #   parent_questionnaire = Questionnaire.new
  #   parent_questionnaire.title = "Parent Reference Questionnaire"
  #   parent_questionnaire.type = "SpQuestionnaire"
  #   parent_questionnaire.save!
  #   
  #   ques_pages = QuestionnairePage.find_all_by_questionnaire_id(3, :order => "position")
  #   ques_pages.each do |old_qp|
  #     new_qp = QuestionnairePage.new
  #     new_qp.questionnaire_id = parent_questionnaire.id
  #     
  #       old_page = Page.find(old_qp.page_id)
  #       new_page = Page.new
  #       new_page.title = old_page.title
  #       new_page.url_name = old_page.url_name
  #       new_page.hidden = old_page.hidden
  #       new_page.save!
  #       
  #       old_page_elements = PageElement.find_all_by_page_id(old_page.id, :order => "position")
  #       old_page_elements.each do |old_pe|
  #         new_pe = PageElement.new
  #         new_pe.page_id = new_page.id
  #         
  #           if(old_pe.page_id != 22 && old_pe.page_id != 25)
  #             old_element = Element.find(old_pe.element_id)
  #             new_element = Element.new
  #             new_element.parent_id = old_element.parent_id #temporary
  #             new_element[:type] = old_element[:type]
  #             new_element.text = old_element.text
  #             new_element.is_required = old_element.is_required
  #             new_element.question_table = old_element.question_table
  #             new_element.question_column = old_element.question_column
  #             new_element.position = old_element.position
  #             new_element.max_length = old_element.max_length
  #             new_element.is_confidential = old_element.is_confidential
  #             new_element.save!
  #             
  #             old_question_options = QuestionOption.find_all_by_question_id(old_element.id, :order => "position")
  #             old_question_options.each do |old_qo|
  #               new_qo = QuestionOption.new
  #               new_qo.question_id = new_element.id
  #               new_qo.option = old_qo.option
  #               new_qo.value = old_qo.option
  #               new_qo.position = old_qo.position
  #               new_qo.save!
  #             end
  #           else
  #             new_element = Element.find(old_pe.element_id)
  #           end
  #                   
  #         new_pe.element_id = new_element.id
  #         new_pe.position = old_pe.position
  #         new_pe.save!
  #       end
  #     
  #     new_qp.page_id = new_page.id
  #     new_qp.position = old_qp.position
  #     new_qp.save!
  #   end
  # end
  
  def self.add_sp_users_to_mpd_tool
    users = SpUser.find(:all, :conditions => "type IN ('SpNationalCoordinator', 'SpRegionalCoordinator', 'SpDirector')")
    users.each do |user|
      # MpdUser.create(:ssm_id => user.ssm_id)
    end
  end
  
  def self.move_birthdates
    answers = SpAnswer.find_all_by_question_id(404)
    answers.each do |answer|
      if !answer.answer.blank?
        app = SpApplication.find(answer.instance_id)
        person = app.person
        person.birth_date = answer.answer
        person.save!
      end
    end
    nil
  end
end
