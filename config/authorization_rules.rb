authorization do
	
	# Access to everything.
	role :developer do
		has_omnipotence
	end

	# District level access.
	role :superintendent do
    
    # Access to user.
    has_permission_on :users, to: [:show, :edit, :update] do
      if_attribute id: is { user.id }
    end
    
    # Access to district.
    has_permission_on :districts, to: [:show, :update] do
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
    
    # Access to students in district.
    has_permission_on :students, to: :manage do
      if_permitted_to :manage, :school
    end
    
    # Access to test scores of students.
    has_permission_on :test_scores, to: [:manage, :dynamic_fields] do
      if_permitted_to :show, :student
    end
    
    # Access to logout.
    has_permission_on :user_sessions, to: :destroy
    
    # Access to export.
    includes :export
    
    # Access to zpass.
    includes :zpass
    
	end

	# School level access.
	role :principal do
    
    # Access to user.
    has_permission_on :users, to: [:show, :update] do
      if_attribute id: is { user.id }
    end
    
    # Access to district.
    has_permission_on :districts, to: :show do
      if_attribute id: is { user.district.id }
    end
    
    # Access to school.
    has_permission_on :schools, to: [:show, :update] do
      if_attribute id: is { user.school_id }
    end
    
    # Access to periods in school.
    has_permission_on :periods, to: :manage do
      if_attribute school_id: is { user.school_id }
    end
    
    # Access to students in school.
    has_permission_on :students, to: :manage do
      if_attribute school_id: is { user.school_id }
    end
    
    # Access to test scores of students.
    has_permission_on :test_scores, to: [:manage, :dynamic_fields] do
      if_permitted_to :show, :student
    end
    
    # Access to logout.
    has_permission_on :user_sessions, to: :destroy
    
    # Access to export.
    includes :export
    
    # Access to zpass.
    includes :zpass
    
	end

	# Class level access.
	role :teacher do
  
    # Access to user.
    has_permission_on :users, to: [:show, :edit, :update] do
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
    has_permission_on :periods, to: [:index, :show] do
      if_attribute users: contains { user }
    end
    
    # Access to students in periods.
    has_permission_on :students, to: [:index, :show] do
      if_permitted_to :show, :periods
    end
    
    # Access to test scores of students.
    has_permission_on :test_scores, to: [:manage, :dynamic_fields] do
      if_permitted_to :show, :student
    end
    
    # Access to logout.
    has_permission_on :user_sessions, to: :destroy
    
    # Access to export.
    includes :export
    
    # Access to zpass.
    includes :zpass
    
	end

	# Default.
	role :default do
    
    # Access to login.
    has_permission_on :user_sessions, to: [:new, :create]
    
	end
  
  # Access to print jobs.
  role :export do
    has_permission_on :districts, to: [:export, :view_request] do
      if_attribute zpass: true
      if_attribute schools: { type_ids: is_not { [] } }
    end
    has_permission_on [:schools, :periods, :students, :users], to: [:export, :view_request] do
      if_permitted_to :zpass, :district 
    end
    has_permission_on :schools, to: [:export, :view_request] do
      if_attribute type_ids: is_not { [] }
    end
    has_permission_on [:periods, :students, :users], to: [:export, :view_request] do
      if_permitted_to :export, :school
    end
  end
  
  # Access to zpass.
  role :zpass do
    has_permission_on :districts, to: :zpass do
      if_attribute zpass: true
    end
    has_permission_on [:schools, :periods, :students, :users], to: :zpass do
      if_attribute district: { zpass: true }
    end
  end

end

privileges do

	# Includes every action.
	privilege :manage do
		includes :index, :print, :show, :edit, :update, :new, :create, :delete
	end

end
