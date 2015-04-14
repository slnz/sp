require 'spec_helper'

describe SpApplication do
  context '#log_changed_project' do
    it 'regenerates a give site' do
      create(:email_template, name: 'Application Moved')
      create(:email_template, name: 'Application Moved - Donation Services')
      app = create(:sp_application, project_id: create(:sp_project).id)
      create(:sp_designation_number, person_id: app.person_id, project_id: app.project_id)
      expect(app).to receive(:regenerate_give_site)
      app.project_id = create(:sp_project).id
      app.save!
    end
  end
end
