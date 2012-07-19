class UsersController < ApplicationController

  before_filter :set_params_id, only: [:show, :edit, :update, :destroy]
  
  def collection
    if params[:search]
      find_collection.includes(:role, school: [:district])
        .search(params[:search]).limit(30)
    else
      termed_collection
    end
  end
  
  def termed_collection
    default = find_collection.includes(:role, school: [:district])
    return default if params[:term] == 'All'
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] || Period.current_term })
  end
    
  # When there is no id passed in, check presence of current user. If
  # there is a current user, set params[:id] to the appropriate id for the
  # current user, otherwise redirect to login page.
  def set_params_id
    unless params[:id]
      if current_user
        params[:id] = current_user.id
      else
        require_user
      end
    end
  end
end
