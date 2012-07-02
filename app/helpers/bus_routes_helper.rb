module BusRoutesHelper

  PARENTS[:bus_routes] = [District]
  
  FIELDS[:bus_routes] = {
    index: [:name, :district],
    show: [:name, :district],
    form: [:name, :district]
  }

end
