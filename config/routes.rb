Sp2::Application.routes.draw do

  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#failed'
  resources :authentications
  
  resources :campuses do
    collection do 
      post :search
    end
  end

  # Sample resource route within a namespace:
  namespace :admin do
    resources :evaluations do
      member do
        get :page
        get :references
        get :print_setup
        get :print
      end
      collection do
        get :evaluate
      end
    end
    
    resource :reports do
      
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
        get :threads, :no
      end
    end
    resources :applications do 
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
  
  resources :projects
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
      collection do
        post :staff_search
      end
    end
  end
  resources :ministry_focuses
  match '/admin' => "admin/projects#dashboard"
  match '/apply' => "applications#apply", :as => :apply
  
  match '/references/done' => "reference_sheets#done"
  
 # match '/media(/:dragonfly)', :to => Dragonfly[:images]


  root :to => "applications#apply"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  
end
