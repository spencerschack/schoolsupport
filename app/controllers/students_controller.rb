class StudentsController < ApplicationController
  
  def find_collection
    super.includes(:school, :bus_route, :bus_stop)
  end

end
