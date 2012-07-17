class UsersController < ApplicationController

  before_filter :set_params_id, only: [:show, :edit, :update, :destroy]
  
  def collection
    default = find_collection.includes(:role, school: [:district])
    return default if params[:term] == 'All'
    
    term_value = case params[:term]
    when 'With No Period' then nil
    when nil then Period.current_term
    else params[:term] end

    default.joins(:periods).where(periods: { term: term_value })
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
