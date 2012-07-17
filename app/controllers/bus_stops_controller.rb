class BusStopsController < ApplicationController
  
  def collection
    super.includes(:district)
  end

end
