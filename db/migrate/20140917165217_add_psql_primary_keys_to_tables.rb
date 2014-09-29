class AddPsqlPrimaryKeysToTables < ActiveRecord::Migration
  def change
    # NOTE this migration might not be required, depending on the state of the psql db
=begin
    tables = %w(sp_application_moves sp_answers sp_applications sp_conditions sp_designation_numbers sp_donations sp_elements sp_email_templates sp_evaluations sp_gospel_in_actions sp_ministry_focuses sp_page_elements sp_pages sp_payments sp_project_gospel_in_actions sp_project_ministry_focuses sp_project_versions sp_projects sp_question_options sp_question_sheets sp_questionnaire_pages sp_references sp_roles sp_staff sp_stats sp_student_quotes sp_users sp_world_regions)
    tables.each do |t|
      execute %|ALTER TABLE #{t} ADD PRIMARY KEY ("id");|
    end
=end
  end
end
