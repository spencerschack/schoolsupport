class PeriodsController < ApplicationController
  
  def find_collection
    default = super.includes(:school).order('periods.name')
    return default if params[:term] == 'All' || params[:term].blank?
    default.where(term: params[:term])
  end

end
