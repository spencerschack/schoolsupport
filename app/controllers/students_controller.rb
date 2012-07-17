class StudentsController < ApplicationController
  
  def collection
    default = find_collection.includes(:school, :bus_route, :bus_stop)
    return default if params[:term] == 'All'
    
    term_value = case params[:term]
    when 'With No Period' then nil
    when nil then Period.current_term
    else params[:term] end

    default.joins(:periods).where(periods: { term: term_value })
  end

end
