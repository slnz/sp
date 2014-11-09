require 'sidekiq/web'
Sp2::Application.routes.draw do

  get "welcome/privacy"

  match '/auth/:provider/callback' => 'authentications#create', via: :get
  match '/auth/failure' => 'authentications#failed', via: :get
  match '/sos' => 'admin/projects#sos', via: [:get, :post]
  match '/admin/sos' => 'admin/projects#sos', via: [:get, :post]
  #post '/fe/applications/:application_id/submit_page' => 'fe/submit_pages#submit'
  resources :authentications

  resources :campuses do
    collection do
      post :search
    end
  end

  namespace :api, defaults: {format: 'json'} do
    api_version(module: 'v1', header: {name: 'API-VERSION', value: 'v1'}, parameter: {name: "version", value: 'v1'}, path: {value: 'v1'}) do
      resources :users, only: [:index, :show]
      resources :people, only: [:index, :show]
      resources :projects, only: [:index, :show]
    end
  end

  # Sample resource route within a namespace:
  namespace :admin do
    resources :donation_services do
      collection do
        get :download
        post :upload
      end
    end
    resources :evaluations do
      member do
        get :page
        get :payments
        get :references
        get :print_setup
        get :print
      end
      collection do
        get :evaluate
      end
    end

    resource :reports do
      get :director
      get :preference
      get :female_openings
      get :male_openings
      get :ministry_focus
      get :evangelism
      get :evangelism_combined
      get :ready_after_deadline
      get :emergency_contact
      get :applications_by_status
      get :mpd_summary
      get :regional
      get :national
      get :partner
      get :region
      get :missional_team
      get :school
      get :applicants
      get :pd_emails
      get :student_emails
      get :project_start_end
      get :fee_by_staff
      get :cc_payments
      get :sending_stats
      get :stats_by_project
      get :projects_summary

      get :total_num_applicants_by_partner_of_project
      get :total_num_applicants_by_region
      get :total_num_applicants_to_all_sps
      get :total_num_applicants_to_wsn_sps_by_area
      get :total_num_applicants_by_efm
      get :total_num_applicants_to_hs_sps
      get :total_num_applicants_to_other_ministry_sps

      get :total_num_participants_by_partner_of_project
      get :total_num_participants_by_region
      get :total_num_participants_to_all_sps
      get :total_num_participants_to_wsn_sps_by_area
      get :total_num_participants_by_efm
      get :total_num_participants_to_hs_sps
      get :total_num_participants_to_other_ministry_sps
    end
    resources :people
    resources :users do
      collection do
        get :search
      end
    end
    resources :projects do
      member do
        post :close, :open, :send_email
        get :email, :download
      end
      collection do
        get :threads, :no, :dashboard, :sos_exceptions
      end
    end
    resources :applications do
      member do
        get :donations
        get :other_donations
        get :waive_fee
      end
      collection do
        get :search
        post :search_results
        get :search_results
      end
    end

    resources :leaders do
      collection do
        post :search, :add_person
      end
    end
  end

  resources :users

  resources :projects do
    collection do
      get :markers
    end
  end

  resources :applications do
    member do
      get :multiple_projects
      get :done
    end
    collection do
      get :closed
      get :apply
    end
    resources :payments do
      member do
        get :approve
      end
      collection do
        post :staff_search
      end
    end
  end
  resources :ministry_focuses
  match '/admin' => "admin/projects#dashboard", via: :get
  match '/apply' => "applications#apply", :as => :apply, via: :get

  match '/references/done' => "reference_sheets#done", via: [:get, :post]

  match '/logout' => "sessions#destroy", :as => :logout, via: [:get, :post, :delete]
  match '/login' => "sessions#new", :as => :login, via: :get

 # match '/media(/:dragonfly)', :to => Dragonfly[:images]

  constraint = lambda { |request| request.session['user_id'] and
                                  User.find(request.session['user_id']).developer? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'monitors/lb' => 'monitors#lb'

  root :to => "applications#apply"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'


end
