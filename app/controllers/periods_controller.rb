class PeriodsController < ApplicationController
  
  def find_collection
    default = super.includes(:school).order('periods.name')
    return default if params[:term] == 'All'
    default.where(term: params[:term] || Term.current)
  end

end
