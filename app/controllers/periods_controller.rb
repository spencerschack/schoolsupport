class PeriodsController < ApplicationController
  
  def collection
    default = find_collection.includes(:school)
    return default if params[:term] == 'All'
    default.where(term: params[:term] || Period.current_term)
  end

end
