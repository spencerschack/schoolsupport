class BusRoutesController < ApplicationController
  
  def find_collection
    super.eager_load(:district).order('bus_routes.name')
  end
  
end
