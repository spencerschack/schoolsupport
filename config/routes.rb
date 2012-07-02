Schoolsupport::Application.routes.draw do

  resources :bus_stops

  resources :bus_routes

  # Error pages.
  get 'errors/not_found'
  get 'errors/forbidden'
  get 'errors/server_error'
  
  # Districts, Schools, Periods, Students, Users
  
  def importable *args
    resources *args do
      yield if block_given?
      match 'import', on: :collection
    end
  end
  
  students  = proc { importable :periods  do; importable :users    end
                     importable :users }
  periods   = proc { importable :students do; importable :users    end
                     importable :users }
  users     = proc { importable :periods  do; importable :students end
                     importable :students do; importable :periods  end }
  schools   = proc { importable :periods,  &periods
                     importable :users,    &users
                     importable :students, &students }
  districts = proc { resources :bus_stops
                     resources :bus_routes }

  importable :districts, &districts
  importable :schools,   &schools
  importable :periods,   &periods
  importable :students,  &students
  importable :users,     &users
  
  # Bus Routes and Stops
  resources :bus_stops
  resources :bus_routes
  
  # Templates, Fields, Fonts
  resources :templates do
    resources :fields
    resources :schools
  end
  resources :fonts
  
  # Print Job
  match 'print_job/new' => 'print_job#new', via: [:get, :post],
    as: 'new_print_job'
  match 'print_job' => 'print_job#create', via: :post
  match 'print_job' => redirect('print_job/new'), via: :get
  
  # Help
  match 'help' => 'help#index'

  # Friendly user session names.
  match 'login' => 'user_sessions#new', via: :get
  match 'login' => 'user_sessions#create', via: :post
  match 'logout' => 'user_sessions#destroy'

  # Not used, but root has to point somewhere.
  root to: 'users#show'

end
