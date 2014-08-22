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

      project = create(:sp_project)
      staff = create(:sp_staff, person_id: user.person.id, project_id: project.id, type: 'PD')

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
      )

      get :preference
      expect(assigns(:applications)[project]).to eq([application])
    end
  end

  context '#male_openings' do
    it 'responds to CSV' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

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


      get :male_openings
      expect(assigns(:percentages)['100']).to include(project)
    end
  end

  context '#female_openings' do
    it 'responds to CSV' do
      create(:sp_director, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

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

      get :partner, partner: 'NW'
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
                           project_id: project.id
      )
      application.update_attribute('status', 'accepted_as_participant')

      get :mpd_summary, project_id: project.id, format: :csv
      expect(response.content_type).to eq('text/csv')
    end

    it 'list applications by mpd summary via HTML -- params[:project_id] present' do
      create(:sp_national_coordinator, user: user)
      session[:cas_user] = 'foo@example.com'
      session[:user_id] = user.id

      project = create(:sp_project)
      year = project.year

      applicant = create(:person)
      application = create(:sp_application,
                           person_id: applicant.id,
                           project_id: project.id
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

    context '#evangelism_combined' do
      it 'list applications by evangelism summary via HTML with params[:partner present]' do
        stub_request(:get, "https://infobase.uscm.org/api/v1//statistics/sp_evangelism_combined?partner=NW").
          to_return(:status => 200, :body => "", :headers => {})

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


        get :evangelism_combined, partner: 'NW'
        # need to create an activity and statistic
        # expect that @statistic equals statistic (in spec)
        # maybe '200' is good enough, not sure
      end
    end
  end
end
