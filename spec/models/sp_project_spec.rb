require 'spec_helper'

describe SpProject do
  before(:each) do
  end
  
  context "#end_date_range" do
    it "should valiate start date is before end date" do
      project = SpProject.new
      project.start_date = 1.month.from_now
      project.end_date = 1.week.from_now
      project.valid?
      expect(project.errors[:base]).to include("goSP.com tab: Student Start Date must be before Student End Date")
    end
    it "should valiate pd start date is pd before end date" do
      project = SpProject.new
      project.pd_start_date = 1.month.from_now
      project.pd_end_date = 1.week.from_now
      project.valid?
      expect(project.errors[:base]).to include("Risk Management tab: PD Start Date must be before PD End Date")
    end
  end

  context "#statistics" do
    it "should work" do
      project = SpProject.new
      stub_request(:get, "https://infobase.uscm.org/api/v1/statistics?filters%5Bactivity_type%5D=SP&filters%5Bevent_id%5D=&filters%5Bsp_year%5D=2014&per_page=0").
        to_return(:status => 200, :body => { "statistics" => [ ] }.to_json, :headers => {})
      project.statistics(2014)
    end
  end

  context "class-level #statistics" do
    it "should work" do
      stub_request(:get, "https://infobase.uscm.org/api/v1/statistics?filters%5Bactivity_type%5D=SP&filters%5Bsp_year%5D=2014&per_page=0").
        to_return(:status => 200, :body => { "statistics" => [ ] }.to_json, :headers => {})
      SpProject.statistics(2014)
    end
  end

  context "#async_set_up_give_sites" do
    it "should work" do
      project = create(:sp_project)
      project.save!
      project.project_summary = "this has now changed"
      project.full_project_description = "this has now changed"
      project.async_set_up_give_sites
    end
  end

  context "#set_up_give_sites", :broken do
    it "should work" do
      project = create(:sp_project)
      app = create(:sp_application, year: 2014, project: project, status: "accepted_as_participant")
      #expect(app).to receive(:set_up_give_site)
      expect_any_instance_of(SpApplication).to receive(:set_up_give_site)
      project.set_up_give_sites
    end
  end

  context "#async_secure_designations_if_necessary" do
    it "should work when going unsecure" do
      project = create(:sp_project, secure: true)
      project.secure = false
      expect(project).to receive(:async).with(:unsecure_designations)
      project.async_secure_designations_if_necessary
    end

    it "should work when going secure" do
      project = create(:sp_project, secure: false)
      project.secure = true
      expect(project).to receive(:async).with(:secure_designations)
      project.async_secure_designations_if_necessary
    end
  end

  context '#secure_designations' do
    it 'should work' do
      project = create(:sp_project, secure: false)
      expect(project).to receive(:update_designations_security).with({ startDate: Date.today.to_s(:db), endDate: 1.year.from_now.to_date.to_s(:db)}, :secure)
      project.secure_designations
    end
  end

  context '#unsecure_designations' do
    it 'should work' do
      project = create(:sp_project, secure: false)
      expect(project).to receive(:update_designations_security).with({}, :unsecure)
      project.unsecure_designations
    end
  end

  context '#update_designations_security' do
    it 'should work' do
      project = create(:sp_project)
      app = create(:sp_application, year: SpApplication.year, project: project, status: "accepted_as_participant", designation_number: '00000dn')
      #stub_request(:post, "http:///designations/00000dn/secureStatus").
      #  to_return(:status => 200, :body => "", :headers => {})
      expect(SpDesignationNumber).to receive(:update_designation_security).with('00000dn', {}, :secure)
      project.update_designations_security({}, :secure)
    end
  end

  context '#current?' do
    it 'should return true with a current project' do
      project = create(:sp_project, project_status: 'open', open_application_date: 1.week.ago, start_date: 1.week.from_now, end_date: 1.month.from_now)
      expect(project.current?).to be true
    end
  end

  context '#gospel_in_action_ids=' do
    it 'should set gospel in action variable' do
      g1 = create(:sp_gospel_in_action)
      g2 = create(:sp_gospel_in_action)
      project = create(:sp_project)
      project.gospel_in_action_ids = [ g1.id, g2.id ]
      expect(project.gospel_in_actions).to eq([g1, g2])
    end
  end

  context '#apd=' do
    it 'should destroy any existing APD staff and set a new OPD' do
      project = create(:sp_project)
      curr_apd = create(:sp_staff, year: 2014, type: 'APD', project_id: project.id, person_id: create(:person).id)
      new_apd = create(:person)
      project.send('apd=', new_apd.id, 2014)
      expect(SpStaff.where(id: curr_apd.id).first).to be nil
      expect(project.apd).to eq(new_apd)
    end
  end

  context '#opd=' do
    it 'should destroy any existing OPD staff and set a new OPD' do
      project = create(:sp_project)
      curr_opd = create(:sp_staff, year: 2014, type: 'OPD', project_id: project.id, person_id: create(:person).id)
      new_opd = create(:person)
      project.send('opd=', new_opd.id, 2014)
      expect(SpStaff.where(id: curr_opd.id).first).to be nil
      expect(project.opd).to eq(new_opd)
    end
  end

  context '#coordinator=' do
    it 'should destroy any existing Coordinator staff and set a new Coordinator' do
      project = create(:sp_project)
      curr_coord = create(:sp_staff, year: 2014, type: 'Coordinator', project_id: project.id, person_id: create(:person).id)
      new_coord = create(:person)
      project.send('coordinator=', new_coord.id, 2014)
      expect(SpStaff.where(id: curr_coord.id).first).to be nil
      expect(project.coordinator).to eq(new_coord)
    end
  end

  context '#validate_partnership' do
    it 'should check that a regional partnership is chosen if they want to accept from partner region only' do
      project = SpProject.new partner_region_only: true, primary_partner: '', secondary_partner: ''
      project.validate_partnership
      expect(project.errors.present?).to be true
    end
    it 'should not add an error if they want to accept from partner region only and a primary partner is chosen' do
      project = SpProject.new partner_region_only: true, primary_partner: 'AA'
      project.validate_partnership
      expect(project.errors.present?).to be false
    end
    it 'should not add an error if they want to accept from partner region only and a secondary partner is chosen' do
      project = SpProject.new partner_region_only: true, primary_partner: 'AA'
      project.validate_partnership
      expect(project.errors.present?).to be false
    end
  end

  context '#end_date_range' do
    it 'should check that end_date, pd_start_date, pd_close_start_date, staff_start_date, student_staff_start_date, date_of_departure are all valid' do
      p = SpProject.new
      p.start_date = 5.days.from_now
      p.end_date = 2.days.from_now
      p.pd_start_date = 5.days.from_now
      p.pd_end_date = 2.days.from_now
      p.pd_close_start_date = 5.days.from_now
      p.pd_close_end_date = 2.days.from_now
      p.staff_start_date = 5.days.from_now
      p.staff_end_date = 2.days.from_now
      p.student_staff_start_date = 5.days.from_now
      p.student_staff_end_date = 2.days.from_now
      p.date_of_departure = 5.days.from_now
      p.date_of_return = 2.days.from_now
      p.end_date_range
      expect(p.errors[:base].detect{ |e| e =~ /Student Start Date must be before Student End Date/ }.present?).to be true
      expect(p.errors[:base].detect{ |e| e =~ /Risk Management tab: PD Start Date must be before PD End Date/ }.present?).to be true
      expect(p.errors[:base].detect{ |e| e =~ /Risk Management tab: PD Start Date \(for closing\) must be before PD Close End Date \(for closing\)/ }.present?).to be true
      expect(p.errors[:base].detect{ |e| e =~ /Risk Management tab: Staff Start Date must be before Staff End Date/ }.present?).to be true
      expect(p.errors[:base].detect{ |e| e =~ /Risk Management tab: Student Staff Start Date must be before Student Staff End Date/ }.present?).to be true
      expect(p.errors[:base].detect{ |e| e =~ /Risk Management tab: Departure \(from the US\) Date must be before Arrival \(in the US\) Date/ }.present?).to be true
    end
  end

  context '#close!' do
    it 'should close' do
      p = create(:sp_project, project_status: 'open')
      p.close!
      p.reload
      expect(p.project_status).to eq('closed')
    end
  end

  context '#open!' do
    it 'should open' do
      p = create(:sp_project, project_status: 'closed')
      p.open!
      p.reload
      expect(p.project_status).to eq('open')
    end
  end

  context '#closed?' do
    it 'should return true if the project is closed' do
      p = create(:sp_project)
      p.close!
      expect(p.closed?).to be true
    end
  end

  context '#open?' do
    it 'should return true if the project is open' do
      p = create(:sp_project)
      p.open!
      expect(p.open?).to be true
    end
  end

  context '#url=' do
    it 'should prepend http://' do
      p = create(:sp_project)
      p.url = 'test.com'
      expect(p.url).to eq('http://test.com')
    end

    it "should not prepend http:// if it's already there" do
      p = create(:sp_project)
      p.url = 'http://test.com'
      expect(p.url).to eq('http://test.com')
    end
  end

  context 'percent_full_methods' do
    it 'should work with #percent_full when values are nil' do
      p = create(:sp_project)
      expect(p.percent_full).to eq(0)
    end
    it 'should work with #percent_full' do
      p = create(:sp_project)
      p.current_students_men = 5
      p.current_students_women = 5
      p.max_accepted_men = 10
      p.max_accepted_women = 10
      expect(p.percent_full).to eq(50)
    end
    it 'should work with #percent_full_men' do
      p = create(:sp_project)
      p.current_students_men = 5
      p.current_students_women = 2
      p.max_accepted_men = 10
      p.max_accepted_women = 10
      expect(p.percent_full_men).to eq(50)
    end
    it 'should work with #percent_full_women' do
      p = create(:sp_project)
      p.current_students_men = 2
      p.current_students_women = 5
      p.max_accepted_men = 10
      p.max_accepted_women = 10
      expect(p.percent_full_women).to eq(50)
    end
  end

  context '#color' do
    it 'should return green when under 50 percent full' do
      p = create(:sp_project)
      p.current_students_men = 2
      p.current_students_women = 2
      p.max_accepted_men = 10
      p.max_accepted_women = 10
      expect(p.color).to eq('green')
    end
    it 'should return green when between 50 and 100 percent full' do
      p = create(:sp_project)
      p.current_students_men = 8
      p.current_students_women = 8
      p.max_accepted_men = 10
      p.max_accepted_women = 10
      expect(p.color).to eq('yellow')
    end
    it 'should return red when at 100 percent' do
      p = create(:sp_project)
      p.current_students_men = 10
      p.current_students_women = 10
      p.max_accepted_men = 10
      p.max_accepted_women = 10
      expect(p.color).to eq('red')
    end
  end

  context '#international' do
    it 'should return No if country is United States' do
      stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=String,MN,United%20States&language=en&sensor=false").
        to_return(:status => 200, :body => @geocode_body, :headers => {})
      p = create(:sp_project, country: 'United States', state: 'MN')
      expect(p.international).to eq('No')
    end
    it 'should return Yes if country is Canada' do
      stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=String,Canada&language=en&sensor=false").
        to_return(:status => 200, :body => @geocode_body, :headers => {})
      p = create(:sp_project, country: 'Canada')
      expect(p.international).to eq('Yes')
    end
    it 'should return No if country is not set' do
      stub_request(:get, "http://maps.googleapis.com/maps/api/geocode/json?address=String,Canada&language=en&sensor=false").
        to_return(:status => 200, :body => @geocode_body, :headers => {})
      p = SpProject.new
      expect(p.international).to eq('No')
    end
  end

  context '#pd_name_non_secure' do
    it 'should work' do
      project = create(:sp_project)
      pd = create(:sp_staff, year: project.year, type: 'PD', project_id: project.id, person_id: create(:person).id)
      expect(project.pd_name_non_secure).to eq(pd.person.informal_full_name)
    end
  end

  context '#pd_name' do
    it 'should return the same thing as pd_name_non_secure if project is at an open country' do
      project = create(:sp_project)
      expect(project).to receive(:country_status).and_return('open')
      expect(project).to receive(:pd_name_non_secure).and_return('bob')
      pd = create(:sp_staff, year: project.year, type: 'PD', project_id: project.id, person_id: create(:person).id)
      expect(project.pd_name).to eq('bob')
    end
    it 'should return nil for a closed country' do
      project = create(:sp_project)
      expect(project).to receive(:country_status).and_return('closed')
      pd = create(:sp_staff, year: project.year, type: 'PD', project_id: project.id, person_id: create(:person).id)
      expect(project.pd_name).to eq(nil)
    end
    it 'should return nil for an open country but secure pd' do
      project = create(:sp_project)
      expect(project).to receive(:country_status).and_return('open')
      pd = create(:sp_staff, year: project.year, type: 'PD', project_id: project.id, person_id: create(:person).id)
      allow(project).to receive(:pd).and_return(pd)
      expect(pd).to receive(:is_secure?).and_return(true)
      expect(project.pd_name).to eq(nil)
    end
  end

  context '#pd_name_non_secure' do
    it 'should work' do
      project = create(:sp_project)
      pd = create(:sp_staff, year: project.year, type: 'PD', project_id: project.id, person_id: create(:person).id)
      expect(project.pd_name_non_secure).to eq(pd.person.informal_full_name)
    end
  end

  context '#apd_name' do
    it 'should return the same thing as apd_name_non_secure if project is at an open country' do
      project = create(:sp_project)
      expect(project).to receive(:country_status).and_return('open')
      expect(project).to receive(:apd_name_non_secure).and_return('bob')
      apd = create(:sp_staff, year: project.year, type: 'APD', project_id: project.id, person_id: create(:person).id)
      expect(project.apd_name).to eq('bob')
    end
    it 'should return nil for a closed country' do
      project = create(:sp_project)
      expect(project).to receive(:country_status).and_return('closed')
      apd = create(:sp_staff, year: project.year, type: 'APD', project_id: project.id, person_id: create(:person).id)
      expect(project.apd_name).to eq(nil)
    end
    it 'should return nil for an open country but secure apd' do
      project = create(:sp_project)
      expect(project).to receive(:country_status).and_return('open')
      apd = create(:sp_staff, year: project.year, type: 'APD', project_id: project.id, person_id: create(:person).id)
      allow(project).to receive(:apd).and_return(apd.person)
      expect(apd.person).to receive(:is_secure?).and_return(true)
      expect(project.apd_name).to eq(nil)
    end
  end

  context '#apd_name_non_secure' do
    it 'should work' do
      project = create(:sp_project)
      apd = create(:sp_staff, year: project.year, type: 'APD', project_id: project.id, person_id: create(:person).id)
      expect(project.apd_name_non_secure).to eq(apd.person.informal_full_name)
    end
  end

  context '#pd_email_non_secure' do
    it 'should return an email when pd present' do
      project = create(:sp_project)
      pd = create(:sp_staff, year: project.year, type: 'PD', project_id: project.id, person_id: create(:person).id)
      allow(project).to receive(:pd).and_return(pd.person)
      a = pd.person.create_current_address
      a.update_attribute :email, "email@email.com"
      expect(project.pd_email_non_secure).to eq("email@email.com")
    end
  end

  context '#apd_email_non_secure' do
    it 'should return an email when apd present' do
      project = create(:sp_project)
      apd = create(:sp_staff, year: project.year, type: 'APD', project_id: project.id, person_id: create(:person).id)
      allow(project).to receive(:apd).and_return(apd.person)
      a = apd.person.create_current_address
      a.update_attribute :email, "email@email.com"
      expect(project.apd_email_non_secure).to eq("email@email.com")
    end
  end

  context '#regional_info' do
    it 'should return an info blob about the region' do
      primary_partner = "PP"
      project = create(:sp_project, primary_partner: primary_partner)
      region_stub = Region.new(spPhone: 'sp_phone', name: 'Name', email: 'email')
      allow(SpProject).to receive(:get_region).with("PP").and_return(region_stub)
      expect(project.regional_info).to eq("Name Regional Office: Phone - sp_phone, Email - email")
    end
  end

  context '#send_leader_reminder_emails' do
    it 'should send leader emails for all ready_status applications for this year' do
      year = SpApplication.year
      project1 = create(:sp_project, year: year, name: 'project1', start_date: 1.week.from_now, end_date: 2.weeks.from_now)
      project2 = create(:sp_project, year: year, name: 'project2', start_date: 1.week.from_now, end_date: 2.weeks.from_now)
      project3 = create(:sp_project, year: year, name: 'project3', start_date: 1.week.from_now, end_date: 2.weeks.from_now)
      app1 = create(:sp_application, year: year, current_project_queue_id: project1.id)
      app1.update_attribute(:status, 'ready')
      app2 = create(:sp_application, year: year, current_project_queue_id: project1.id)
      app2.update_attribute(:status, 'ready')
      app3 = create(:sp_application, year: year, current_project_queue_id: project2.id)
      app3.update_attribute(:status, 'ready')
      app4 = create(:sp_application, year: year, current_project_queue_id: project2.id)
      app3.update_attribute(:status, 'ready')
      app5 = create(:sp_application, year: year, current_project_queue_id: project3.id)
      app5.update_attribute(:status, 'ready')
      app6 = create(:sp_application, year: year, current_project_queue_id: project3.id)
      app6.update_attribute(:status, 'ready')
      apd = create(:sp_staff, year: year, type: 'PD', project_id: project1.id, person_id: create(:person).id)
      opd = create(:sp_staff, year: year, type: 'PD', project_id: project2.id, person_id: create(:person).id)
      # only the first two projects have apd/opds
      expect(ProjectMailer).to receive(:deliver_leader_reminder).with(satisfy{ |p| p == project1 })
      expect(ProjectMailer).to receive(:deliver_leader_reminder).with(satisfy{ |p| p == project2 })
      SpProject.send_leader_reminder_emails
    end
  end

  context '#male_applicants_count' do
    it 'should work for the current year' do
      year = SpApplication.year
      project = create(:sp_project, year: year, current_applicants_men: 5)
      expect(project.male_applicants_count).to eq(5)
    end
    it 'should work for a different year' do
      year = SpApplication.year
      project = create(:sp_project)
      app1 = create(:sp_application, project: project, person_id: create(:person, gender: '1').id)
      app2 = create(:sp_application, project: project, person_id: create(:person, gender: '1').id)
      app3 = create(:sp_application, project: project, person_id: create(:person, gender: '1').id)
      app4 = create(:sp_application, project: project, person_id: create(:person, gender: '1').id)
      app5 = create(:sp_application, project: project, person_id: create(:person, gender: '1').id)
      SpApplication.where(id: [app1.id, app2.id, app3.id, app4.id, app5.id]).update_all(year: year - 1, status: 'accepted_as_participant')
      project.year = year

      expect(project.male_applicants_count(year - 1)).to eq(5)
    end
  end
end
