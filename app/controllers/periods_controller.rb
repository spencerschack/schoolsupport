class PeriodsController < ApplicationController
  
  def find_collection
    default = super.includes(:school)
    return default if params[:term] == 'All'
    default.where(term: params[:term] || Term.current)
  end

end
