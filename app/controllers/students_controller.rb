class StudentsController < ApplicationController
  
  def find_collection
    default = super.includes(:school, :bus_route, :bus_stop).order('students.last_name')
    return default if params[:term] == 'All' || params[:term].blank?
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] })
  end

end
