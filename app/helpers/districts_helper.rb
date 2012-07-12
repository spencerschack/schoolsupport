module DistrictsHelper
  
  FIELDS[:districts] = {
    index: [:name],
    show: { fields: [:name],
      relations: [:schools, :users, :students, :bus_routes, :bus_stops]},
    form: { fields: [:identifier, :name], relations: [] }
  }
  
end
