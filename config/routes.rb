Schoolsupport::Application.routes.draw do
  
  # Helper function that adds 'import' and 'export' actions in addition to
  # resources.
  def helper *args
    resources *args do
      match 'import', on: :collection
      match 'export', on: :collection
      match 'export', on: :member
      yield if block_given?
    end
  end

  # Error pages.
  get 'errors/not_found'
  get 'errors/forbidden'
  get 'errors/server_error'
  
  # Districts, Schools, Periods, Students, Users
  
  students  = proc { helper :periods  do; helper :users    end
                     helper :users }
  periods   = proc { helper :students do; helper :users    end
                     helper :users }
  users     = proc { helper :periods  do; helper :students end
                     helper :students do; helper :periods  end }
  schools   = proc { helper :periods,  &periods
                     helper :users,    &users
                     helper :students, &students }
  districts = proc { helper :bus_stops
                     helper :bus_routes
                     helper :schools
                     helper :users
                     helper :students }

  helper :districts, &districts
  helper :schools,   &schools
  helper :periods,   &periods
  helper :students,  &students
  helper :users,     &users
  
  # Bus Routes and Stops
  helper :bus_stops
  helper :bus_routes
  
  # Templates, Fields, Fonts
  resources :templates do
    resources :fields
    resources :schools
  end
  resources :fonts
  
  # Help
  match 'help' => 'help#index'

  # Friendly user session names.
  match 'login' => 'user_sessions#new', via: :get
  match 'login' => 'user_sessions#create', via: :post
  match 'logout' => 'user_sessions#destroy'

  # Not used, but root has to point somewhere.
  root to: 'users#show'

end
