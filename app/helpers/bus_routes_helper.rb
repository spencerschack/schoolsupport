module BusRoutesHelper

  PARENTS[:bus_routes] = [District]
  
  FIELDS[:bus_routes] = {
    index: [:name, :color_name, :district],
    show: [:name, :color_name, :color_value, :district],
    form: [:name, :color_name, :color_value, :district]
  }

end
