module DistrictsHelper
  
  FIELDS[:districts] = {
    index: [:name],
    show: [:name, :schools, :users, :students, :bus_routes, :bus_stops],
    form: [:name]
  }
  
end
