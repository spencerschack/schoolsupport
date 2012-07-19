class BusRoutesController < ApplicationController
  
  def collection
    if params[:search]
      super.includes(:district).search(params[:search]).limit(30)
    else
      super.includes(:district)
    end
  end
  
end
