class StudentsController < ApplicationController
  
  def find_collection
    default = super.includes(:school, :bus_route, :bus_stop)
    return default if params[:term] == 'All'
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] || Term.current })
  end

end
