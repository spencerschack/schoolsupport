Schoolsupport::Application.routes.draw do
  
  mount Resque::Server.new, at: '/resque'

  # Helper function that adds 'import' and 'export' actions in addition to
  # resources.
  def helper *args
    resources *args do
      importable
      yield if block_given?
    end
  end
  
  # Extract export routes.
  def exportable
    #match 'export/view_request', action: 'view_request', on: :collection
    #match 'export(/:export_kind(/:export_id))', action: 'export',
    #  on: :collection, as: 'export'
    #match 'export(/:export_kind(/:export_id))', action: 'export',
    #  on: :member, as: 'export'
  end
  
  # Extract import routes.
  def importable
    match 'import', on: :collection
  end
  
  # Districts, Schools, Periods, Students, Users, and Tests
  
  def test_scores
    resources :test_scores do
      importable
      match 'dynamic_fields(/:test_model_id)', on: :collection, action: :dynamic_fields
      match 'compare', on: :collection
    end
  end
  def test_models
    resources :test_models do
      resources :test_attributes
    end
  end
  def test_groups
    resources :test_groups do
      test_models
    end
  end
  def students
    helper :students do
      post 'export', on: :collection
      helper :periods do
        helper :users
      end
      helper :users
      test_scores
    end
  end
  def periods
    helper :periods do
      helper :students do
        post 'export', on: :collection
        helper :users
        test_scores
      end
      helper :users
      test_scores
    end
  end
  def users
    helper :users do
      helper :periods do
        helper :students do
          post 'export', on: :collection
          test_scores
        end
        test_scores
      end
      helper :students do
        post 'export', on: :collection
        helper :periods do
          test_scores
        end
        test_scores
      end
      test_scores
    end
  end
  def schools
    helper :schools do
      periods
      users
      students
      test_scores
    end
  end
  def districts
    helper :districts do
      helper :bus_stops
      helper :bus_routes
      schools
      users
      students
      test_scores
      test_groups
    end
  end

  districts
  schools
  periods
  students
  users
  test_models
  test_groups
  
  # Bus Routes and Stops
  helper :bus_stops
  helper :bus_routes
  
  # Templates, Pdfs, Types, Fields, Fonts, and Settings
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
  resources :settings
  
  # Export List Items
  match 'export_list_items' => 'export_list_items#index'
  match 'export_list_items/clear' => 'export_list_items#clear', via: 'POST'
  match 'export_list_items/toggle' => 'export_list_items#toggle', via: 'POST'
  
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
