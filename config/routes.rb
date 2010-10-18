Sp2::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  namespace :admin do
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
    resources :applications
    
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
    end
    collection do
      get :closed
      get :apply
    end
  end
  resources :ministry_focuses
  match '/admin' => "admin/projects#dashboard"
  match '/apply' => "applications#apply"
  
 # match '/media(/:dragonfly)', :to => Dragonfly[:images]


  root :to => "applications#apply"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
  
end
