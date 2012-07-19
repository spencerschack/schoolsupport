class StudentsController < ApplicationController
  
  def collection
    if params[:search]
      find_collection.includes(:school, :bus_route, :bus_stop)
        .search(params[:search]).limit(30)
    else
      termed_collection
    end
  end
  
  def termed_collection
    default = find_collection.includes(:school, :bus_route, :bus_stop)
    return default if params[:term] == 'All'
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] || Period.current_term })
  end

end
