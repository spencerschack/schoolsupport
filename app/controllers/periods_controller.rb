class PeriodsController < ApplicationController
  
  def find_collection
    super.includes(:school)
  end

end
