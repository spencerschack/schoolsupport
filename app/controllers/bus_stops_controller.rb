class BusStopsController < ApplicationController
  
  def find_collection
    super.eager_load(:district).order('bus_stops.name')
  end

end
