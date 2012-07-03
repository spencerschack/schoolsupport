module BusRoutesHelper

  PARENTS[:bus_routes] = [District]
  
  FIELDS[:bus_routes] = {
    index: [:name, :color, :district],
    show: [:name, :color, :district],
    form: [:name, :color, :district]
  }

end
