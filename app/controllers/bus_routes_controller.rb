class BusRoutesController < ApplicationController
  
  def collection
    super.includes(:district)
  end
  
end
