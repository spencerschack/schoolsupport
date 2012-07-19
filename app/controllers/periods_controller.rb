class PeriodsController < ApplicationController
  
  def collection
    if params[:search]
      find_collection.includes(:school)
        .search(params[:search]).limit(30)
    else
      termed_collection
    end
  end
  
  def termed_collection
    default = find_collection.includes(:school)
    return default if params[:term] == 'All'
    default.where(term: params[:term] || Period.current_term)
  end

end
