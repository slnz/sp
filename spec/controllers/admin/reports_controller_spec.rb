require 'spec_helper'

describe Admin::ReportsController do
  let(:user) { create(:user, person: create(:person)) }

  context '#show' do
    it 'determines if you are a director' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :show

      expect(response).to redirect_to(action: :director)
    end
  end

  context '#preference' do
    it 'shows applications that prefer a project' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      project = create(:sp_project, year: Date.today.year)
      staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      get :preference
      expect(assigns(:applications)[project]).to eq([application].to_a)
    end
  end

  context '#male_openings' do
    it 'responds to CSV' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id
      create(:sp_project)
      create(:sp_project)
      create(:sp_project)

      get :male_openings, format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'calculates percentage of men in a project via HTML - 0-50%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_men = 2
      open_application_date = Date.today - 30
      start_date = Date.today
      end_date = Date.today + 60

      project = create(:sp_project,
                       max_accepted_men: max_accepted_men,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person, gender: '1')
      application = create(:sp_application,
                            person_id: applicant.id,
                            project_id: project.id
      )
      application.update_attributes(status: 'accepted_as_participant')

      create(:sp_project)
      create(:sp_project)
      create(:sp_project)

      get :male_openings
      expect(assigns(:percentages)['0-50']).to include(project)
    end
  end

  context '#male_openings' do
    it 'calculates percentage of men in a project via HTML - 51-99%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_men = 3
      open_application_date = Date.today - 30
      start_date = Date.today
      end_date = Date.today + 60
      project = create(:sp_project,
                       max_accepted_men: max_accepted_men,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant1 = create(:person, gender: 1)
      application1 = create(:sp_application,
                            person_id: applicant1.id,
                            project_id: project.id
      )
      applicant2 = create(:person, gender: 1)
      application2 = create(:sp_application,
                            person_id: applicant2.id,
                            project_id: project.id
      )
      application1.update_attributes(status: 'accepted_as_participant')
      application2.update_attributes(status: 'accepted_as_participant')

      create(:sp_project)
      create(:sp_project)
      create(:sp_project)

      get :male_openings
      expect(assigns(:percentages)['51-99']).to include(project)
    end
  end

  context '#male_openings' do
    it 'calculates percentage of men in a project via HTML - 100%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_men = 1
      open_application_date = Date.today - 30
      start_date = Date.today
      end_date = Date.today + 60
      project = create(:sp_project,
                       max_accepted_men: max_accepted_men,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person, gender: '1')
      application = create(:sp_application,
                            person_id: applicant.id,
                            project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')

      create(:sp_project)
      create(:sp_project)
      create(:sp_project)

      get :male_openings
      expect(assigns(:percentages)['100']).to include(project)
    end
  end

  context '#female_openings' do
    it 'responds to CSV' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      create(:sp_project)
      create(:sp_project)
      create(:sp_project)
      get :female_openings, format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'calculates percentage of women in a project via HTML - 0-50%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_women = 2
      open_application_date = Date.today - 30
      start_date = Date.today
      end_date = Date.today + 60

      project = create(:sp_project,
                       max_accepted_women: max_accepted_women,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person, gender: 0)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attributes(status: 'accepted_as_participant')


      get :female_openings
      expect(assigns(:percentages)['0-50']).to include(project)
    end
  end

  context '#female_openings' do
    it 'calculates percentage of women in a project via HTML - 51-99%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_women = 3
      open_application_date = Date.today - 30
      start_date = Date.today
      end_date = Date.today + 60
      project = create(:sp_project,
                       max_accepted_women: max_accepted_women,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant1 = create(:person, gender: 0)
      application1 = create(:sp_application,
                            person_id: applicant1.id,
                            project_id: project.id
      )
      applicant2 = create(:person, gender: 0)
      application2 = create(:sp_application,
                            person_id: applicant2.id,
                            project_id: project.id
      )
      application1.update_attributes(status: 'accepted_as_participant')
      application2.update_attributes(status: 'accepted_as_participant')


      get :female_openings
      expect(assigns(:percentages)['51-99']).to include(project)
    end
  end

  context '#female_openings' do
    it 'calculates percentage of women in a project via HTML - 100%' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      max_accepted_women = 1
      open_application_date = Date.today - 30
      start_date = Date.today
      end_date = Date.today + 60
      project = create(:sp_project,
                       max_accepted_women: max_accepted_women,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person, gender: '0')
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attributes(status: 'accepted_as_participant')

      get :female_openings
      expect(assigns(:percentages)['100']).to include(project)
    end
  end

  context '#ministry_focus' do
    it 'sorts projects by ministry focus via CSV' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      focus = SpMinistryFocus.create(name: 'String')
      create(:sp_project_ministry_focus, ministry_focus: focus)
      create(:sp_project_ministry_focus, ministry_focus: focus)
      create(:sp_project_ministry_focus, ministry_focus: focus)

      get :ministry_focus, focus_id: focus.id, format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'sorts projects by ministry focus' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      focus = SpMinistryFocus.create(name: 'String')

      get :ministry_focus, focus_id: focus.id
      expect(SpMinistryFocus.order(:name)).to eq([focus])
    end
  end

  context '#partner' do
    it 'lists the applications for partnerships via CSV' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      get :partner, partner: 'NW', format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'lists the applications for partnerships via HTML' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = 30.days.ago
      start_date = 30.days.from_now
      end_date = 60.days.from_now
      partnerships = 'NW'

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date,
                       primary_partner: partnerships,
                       secondary_partner: partnerships
      )

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      get :partner, partner: 'NW', format: 'csv'
      expect(assigns(:projects)).to eq([project])
    end

    it 'lists the applications for partnerships via HTML params[:partner] not present' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      partnerships = 'NW'

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date,
                       primary_partner: partnerships,
                       secondary_partner: partnerships
      )

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      get :partner
      expect(assigns(:partners)).to eq(SpProject.connection.select_values('select distinct primary_partner from sp_projects order by primary_partner').reject!(&:blank?))
    end
  end

  context '#mpd_summary' do
    it 'list applications by mpd summary via CSV -- params[:project_id] present' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      project = create(:sp_project)
      year = project.year

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           year: year
      )
      designation_number = create(:sp_designation_number, person: applicant, project: project)
      create(:sp_donation, designation_number: designation_number.designation_number, donation_date: Time.new(year - 1, 10, 2))
      application.update_attribute('status', 'accepted_as_participant')

      get :mpd_summary, project_id: project.id, format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'list applications by mpd summary via HTML -- params[:project_id] present' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      year = SpApplication.year
      project = create(:sp_project, year: year)

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           year: year
      )
      application.update_attribute('status', 'accepted_as_participant')

      get :mpd_summary, project_id: project.id
      expect(assigns(:applications)).to eq(project.sp_applications.joins(:person).includes(:person).order('lastName, firstName').accepted.for_year(year))
    end

    it 'list applications by mpd summary via HTML -- SpNationalCoordinator' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      year = project.year

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')

      get :mpd_summary
      expect(assigns(:projects)).to eq(SpProject.current.order("name ASC"))
    end

    it 'list applications by mpd summary via HTML -- SpRegionalCoordinator' do
      staff = create(:sp_regional_coordinator, user: user, person: user.person)
      user.person.update(region: 'NW', ministry: 'Campus Ministry')

      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      partnerships = 'NW'

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date,
                       primary_partner: partnerships,
                       secondary_partner: partnerships
      )
      year = project.year

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')

      get :mpd_summary
    end

    it 'list applications by mpd summary via HTML -- SpRegionalCoordinator or SpDirector' do
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = Date.today + 30
      end_date = Date.today + 60
      partnerships = 'NW'

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date,
                       primary_partner: partnerships,
                       secondary_partner: partnerships
      )
      year = project.year
      staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')

      get :mpd_summary
      expect(assigns(:project)).to eq(project)
    end

    context '#evangelism' do
      it 'list applications by evangelism via CSV with params[:project_id]' do
        session[:cas_user] = 'foo@example.com'
        session[:user_id] = user.id

        open_application_date = Date.today - 30
        start_date = Date.today + 30
        end_date = Date.today + 60
        partnerships = 'NW'

        project = create(:sp_project,
                         start_date: start_date,
                         end_date: end_date,
                         open_application_date: open_application_date,
                         primary_partner: partnerships,
                         secondary_partner: partnerships
        )
        year = project.year
        staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

        stub_request(:get, "https://infobase.uscm.org/api/v1/statistics?filters%5Bactivity_type%5D=SP&filters%5Bevent_id%5D=#{project.id}&filters%5Bsp_year%5D=&per_page=1").
          to_return(:status => 200, :body => '{"statistics":[{"sp_year":"year"}]}', :headers => {})

        get :evangelism, project_id: project.id, format: 'csv'
      end
    end
    context '#evangelism_combined' do
      it 'list applications by evangelism summary via HTML with params[:partner present]' do
        stub_request(:get, "https://infobase.uscm.org/api/v1//statistics/sp_evangelism_combined?partner=NW").
          to_return(:status => 200, :body => '{"statistics":[{"sp_year":"year"}]}', :headers => {})

        session[:cas_user] = 'foo@example.com'
        session[:user_id] = user.id

        open_application_date = Date.today - 30
        start_date = Date.today + 30
        end_date = Date.today + 60
        partnerships = 'NW'

        project = create(:sp_project,
                         start_date: start_date,
                         end_date: end_date,
                         open_application_date: open_application_date,
                         primary_partner: partnerships,
                         secondary_partner: partnerships
        )
        year = project.year
        staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

        get :evangelism_combined, partner: 'NW', format: 'csv'
      end
    end
  end

  context "#emergency_contact" do
    it 'lists all emergency contacts' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      year = project.year
      sp_staff_pd = create(:sp_staff_pd, year: year, sp_project: project, person: create(:person))

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')

      get :emergency_contact, format: 'csv'
      expect(assigns(:projects)).to eq(SpProject.current.order("name ASC"))
    end
  end

  context "#ready_after_deadline" do
    it 'for a national coordinator, it lists all applications ready after the deadlines' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      year = project.year
      sp_staff_pd = create(:sp_staff_pd, year: year, sp_project: project, person: create(:person))

      d1 = Date.parse("Dec 11, #{SpApplication.year - 1}")
      d2 = Date.parse("Jan 25, #{SpApplication.year}")
      d3 = Date.parse("Feb 25, #{SpApplication.year}")
      # match first deadline
      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready',
                           completed_at: d1
      )
      # match second deadline
      project2 = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      applicant1 = create(:person)
      application1 = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project2.id,
                           status: 'ready',
                           completed_at: d2
      )
      # match third deadline
      project3 = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      applicant2 = create(:person)
      application2 = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project3.id,
                           status: 'ready',
                           completed_at: d3
      )



      get :ready_after_deadline, format: 'csv'
      expect(assigns(:projects)).to eq(SpProject.current.order("name ASC"))
    end
  end

  context "#applications_by_status" do
    it 'should show applications by status' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      year = project.year
      sp_staff_pd = create(:sp_staff_pd, year: year, sp_project: project, person: create(:person))

      d1 = Date.parse("Dec 11, #{SpApplication.year - 1}")
      d2 = Date.parse("Jan 25, #{SpApplication.year}")
      d3 = Date.parse("Feb 25, #{SpApplication.year}")
      # match first deadline
      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready',
                           completed_at: d1
      )
      # match second deadline
      project2 = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      applicant2 = create(:person)
      application2 = create(:sp_application,
                           person_id: applicant2.id,
                           project_id: project2.id,
                           status: 'accepted_as_participant',
                           completed_at: d2
      )
      # match third deadline
      project3 = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      applicant3 = create(:person)
      application3 = create(:sp_application,
                           person_id: applicant3.id,
                           project_id: project3.id,
                           status: 'accepted_as_student_staff',
                           completed_at: d3
      )

      get :applications_by_status, format: 'csv'
      expect(assigns(:projects)).to eq(SpProject.current.order("name ASC"))
    end
  end

  context "#region" do
    it 'should report applications by region' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      year = project.year
      sp_staff_pd = create(:sp_staff_pd, year: year, sp_project: project, person: create(:person))

      d1 = Date.parse("Dec 11, #{SpApplication.year - 1}")
      d2 = Date.parse("Jan 25, #{SpApplication.year}")
      d3 = Date.parse("Feb 25, #{SpApplication.year}")
      # match first deadline
      applicant = create(:person, region: "GL")
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready',
                           completed_at: d1
      )
      # match second deadline
      project2 = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      applicant2 = create(:person, region: "GP")
      application2 = create(:sp_application,
                           person_id: applicant2.id,
                           project_id: project2.id,
                           status: 'accepted_as_participant',
                           completed_at: d2
      )
      # match third deadline
      project3 = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )
      applicant3 = create(:person, region: "GL")
      application3 = create(:sp_application,
                           person_id: applicant3.id,
                           project_id: project3.id,
                           status: 'accepted_as_student_staff',
                           completed_at: d3
      )

      get :region, region: 'GL', format: 'csv'
      expect(assigns(:applications)).to eq([application, application3])
    end
  end

  context "#missional_team" do
    it 'should render all applications for a specific team into csv' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      # called from first applicant (person) create below
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=UW").
        to_return(:status => 200, :body => '{"target_areas":[{"name":"UW"}]}', :headers => {})
      # called from second applicant (person) create below
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=ABC").
        to_return(:status => 200, :body => '{"target_areas":[{"name":"ABC"}]}', :headers => {})
      # called from Infobase::TargetArea.get in reports
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bteam_id%5D=UW").
        to_return(:status => 200, :body => '{"target_areas":[{"name":"UW"}]}', :headers => {})
      # called from Infobase::Team.find in reports
      stub_request(:get, "https://infobase.uscm.org/api/v1/teams/UW").
        to_return(:status => 200, :body => '{"teams":[{"name":"UW"}]}', :headers => {})

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )

      # match applicant based on campus
      applicant = create(:person, campus: "UW")
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready'
      )

      # match applicant based on campus
      applicant2 = create(:person, campus: "ABC")
      application2 = create(:sp_application,
                            person_id: applicant2.id,
                            project_id: project.id,
                            status: 'ready'
      )

      get :missional_team, team: "UW", format: 'csv'
      expect(assigns(:applications)).to eq([application])
    end
  end

  context "#school" do
    it 'should render all applications for a specific school into csv' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      # called from first applicant (person) create below
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=UW").
        to_return(:status => 200, :body => '{"target_areas":[{"name":"UW"}]}', :headers => {})
      # called from second applicant (person) create below
      stub_request(:get, "https://infobase.uscm.org/api/v1/target_areas?filters%5Bname%5D=ABC").
        to_return(:status => 200, :body => '{"target_areas":[{"name":"ABC"}]}', :headers => {})

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )

      # match applicant based on campus
      applicant = create(:person, campus: "UW")
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready'
      )

      # match applicant based on campus
      applicant2 = create(:person, campus: "ABC")
      application2 = create(:sp_application,
                            person_id: applicant2.id,
                            project_id: project.id,
                            status: 'ready'
      )

      get :school, school: "UW", format: 'csv'
      expect(assigns(:applications)).to eq([application])
    end
  end

  context "#applicants" do
    it 'should render all applications for a specific school into csv' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      open_application_date = Date.today - 30
      start_date = 1.month.from_now
      end_date = 2.months.from_now

      project = create(:sp_project,
                       year: Date.today.year,
                       start_date: start_date,
                       end_date: end_date,
                       open_application_date: open_application_date
      )

      # match applicant based on campus
      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id,
                           status: 'ready'
      )

      # match applicant based on campus
      applicant2 = create(:person)
      application2 = create(:sp_application,
                            person_id: applicant2.id,
                            project_id: project.id,
                            status: 'ready'
      )

      get :applicants, format: 'csv'
      expect(assigns(:applications)).to eq([application, application2])
    end
  end
end
