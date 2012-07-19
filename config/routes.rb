Schoolsupport::Application.routes.draw do

  resources :pdfs

  # Helper function that adds 'import' and 'export' actions in addition to
  # resources.
  def helper *args
    resources *args do
      match 'import', on: :collection
      match 'export(/:export_type(/:export_id))', action: 'export',
        on: :collection, as: 'export'
      match 'export(/:export_type(/:export_id))', action: 'export',
        on: :member, as: 'export'
      yield if block_given?
    end
  end
  
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
                     helper :schools,  &schools
                     helper :users,    &users
                     helper :students, &students }

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
    resources :pdfs do
      resources :schools
    end
    resources :fields
  end
  resources :fonts
  
  # Help
  match 'help' => 'help#index'
  match 'help/*path' => 'help#page'

  # Friendly user session names.
  match 'login' => 'user_sessions#new', via: :get
  match 'login' => 'user_sessions#create', via: :post
  match 'logout' => 'user_sessions#destroy'

  # Not used, but root has to point somewhere.
  root to: 'users#show'

end
