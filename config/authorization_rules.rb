authorization do
	
	# Access to everything.
	role :developer do
		has_omnipotence
	end

	# District level access.
	role :superintendent do
    
    # Access to user.
    has_permission_on :users, to: [:show, :edit, :update, :print] do
      if_attribute id: is { user.id }
    end
    
    # Access to district.
    has_permission_on :districts, to: [:show, :update, :print] do
      if_attribute id: is { user.district.id }
    end
    
    # Access to schools in district.
    has_permission_on :schools, to: :manage do
      if_attribute district: is { user.district }
    end
    
    # Access to periods in district.
    has_permission_on :periods, to: :manage do
      if_permitted_to :manage, :school
    end
    
    # Access to students district.
    has_permission_on :students, to: :manage do
      if_permitted_to :manage, :school
    end
    
    # Access to logout.
    has_permission_on :user_sessions, to: :destroy
    
    # Access to templates, print_jobs, and user_sessions.
    includes :print_jobs
    
	end

	# School level access.
	role :principal do
    
    # Access to user.
    has_permission_on :users, to: [:show, :update, :print] do
      if_attribute id: is { user.id }
    end
    
    # Access to district.
    has_permission_on :districts, to: :show do
      if_attribute id: is { user.district.id }
    end
    
    # Access to school.
    has_permission_on :schools, to: [:show, :update, :print] do
      if_attribute id: is { user.school_id }
    end
    
    # Access to periods in school.
    has_permission_on :periods, to: :manage do
      if_permitted_to :show, :school
    end
    
    # Access to students in school.
    has_permission_on :students, to: :manage do
      if_permitted_to :show, :school
    end
    
    # Access to logout.
    has_permission_on :user_sessions, to: :destroy
    
    # Access to templates, print_jobs, and user_sessions.
    includes :print_jobs
    
	end

	# Class level access.
	role :teacher do
  
    # Access to user.
    has_permission_on :users, to: [:show, :edit, :update, :print] do
      if_attribute id: is { user.id }
    end
    
    # Access to district.
    has_permission_on :districts, to: :show do
      if_attribute id: is { user.district.id }
    end
    
    # Access to schoool.
    has_permission_on :schools, to: :show do
      if_attribute id: is { user.school_id }
    end
    
    # Access to periods assigned.
    has_permission_on :periods, to: [:index, :show, :print] do
      if_attribute users: contains { user }
    end
    
    # Access to students in periods.
    has_permission_on :students, to: [:index, :show, :print] do
      if_attribute periods: { users: contains { user } }
    end
    
    # Access to logout.
    has_permission_on :user_sessions, to: :destroy
    
    # Access to templates, print_jobs, and user_sessions.
    includes :print_jobs
    
	end

	# Default.
	role :default do
    
    # Access to login.
    has_permission_on :user_sessions, to: [:new, :create]
    
	end
  
  # Access to print jobs.
  role :print_jobs do
    has_permission_on :print_jobs, to: [:new, :create]
  end

end

privileges do

	# Includes every action.
	privilege :manage do
		includes :index, :import, :print, :show, :edit, :update, :new, :create, :destroy
	end

end