Schoolsupport::Application.routes.draw do

  # Helper function that adds 'import' and 'export' actions in addition to
  # resources.
  def helper *args
    resources *args do
      importable
      exportable
      yield if block_given?
    end
  end
  
  # Extract export routes.
  def exportable
    match 'export(/:export_kind(/:export_id))', action: 'export',
      on: :collection, as: 'export'
    match 'export(/:export_kind(/:export_id))', action: 'export',
      on: :member, as: 'export'
  end
  
  # Extract import routes.
  def importable
    match 'import', on: :collection
  end
  
  # Districts, Schools, Periods, Students, Users, and Tests
  
  test_scores = proc { resources :test_attributes }
  students    = proc { helper :periods  do; helper :users    end
                       helper :users
                       resources :test_scores do; importable end }
  periods     = proc { helper :students do; helper :users    end
                       helper :users }
  users       = proc { helper :periods  do; helper :students end
                       helper :students do; helper :periods  end }
  schools     = proc { helper :periods,  &periods
                       helper :users,    &users
                       helper :students, &students }
  districts   = proc { helper :bus_stops
                       helper :bus_routes
                       helper :schools,  &schools
                       helper :users,    &users
                       helper :students, &students
                       resources :test_models, &test_scores }

  helper :districts, &districts
  helper :schools,   &schools
  helper :periods,   &periods
  helper :students,  &students
  helper :users,     &users
  resources :test_models, &test_scores
  
  # Bus Routes and Stops
  helper :bus_stops
  helper :bus_routes
  
  # Templates, Pdfs, Types, Fields, and Fonts
  resources :templates do
    resources :pdfs do
      resources :types do
        resources :schools
        exportable
      end
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
