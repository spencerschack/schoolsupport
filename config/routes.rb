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
  
  test_scores = proc { importable
                       match 'dynamic_fields(/:test_model_id)', on: :collection, action: :dynamic_fields
                       match 'table', on: :collection, action: :index
                       match 'pie', on: :collection
                       match 'line', on: :collection
                       match 'compare', on: :collection }
  test_models = proc { resources :test_attributes }
  test_groups = proc { resources :test_models, &test_models }
  students    = proc { helper :periods  do; helper :users    end
                       helper :users
                       resources :test_scores, &test_scores}
  periods     = proc { helper :students do
                         helper :users
                         resources :test_scores, &test_scores
                       end
                       helper :users
                       resources :test_scores, &test_scores }
  users       = proc { helper :periods do
                         helper :students do
                           resources :test_scores, &test_scores
                         end
                       end
                       helper :students do
                         helper :periods do
                           resources :test_scores, &test_scores
                         end
                       end
                       resources :test_scores, &test_scores }
  schools     = proc { helper :periods,  &periods
                       helper :users,    &users
                       helper :students, &students
                       resources :test_scores, &test_scores }
  districts   = proc { helper :bus_stops
                       helper :bus_routes
                       helper :schools,  &schools
                       helper :users,    &users
                       helper :students, &students
                       resources :test_scores, &test_scores
                       resources :test_groups, &test_groups }

  helper :districts, &districts
  helper :schools,   &schools
  helper :periods,   &periods
  helper :students,  &students
  helper :users,     &users
  resources :test_models, &test_models
  resources :test_groups, &test_groups
  
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
