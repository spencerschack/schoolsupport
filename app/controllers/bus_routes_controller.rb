class BusRoutesController < ApplicationController
  
  def find_collection
    super.includes(:district)
  end
  
end
