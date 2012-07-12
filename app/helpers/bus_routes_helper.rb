module BusRoutesHelper

  PARENTS[:bus_routes] = [District]
  
  FIELDS[:bus_routes] = {
    index: [:name, :color_name, :district],
    show: { fields: [:name, :color_name, :color_value], relations: [:district] },
    form: { fields: [:name, :color_name, :color_value], relations: [:district] }
  }

end
