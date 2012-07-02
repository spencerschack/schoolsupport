module BusStopsHelper
  
  PARENTS[:bus_stops] = [District]
  
  FIELDS[:bus_stops] = {
    index: [:name, :district],
    show: [:name, :district],
    form: [:name, :district]
  }
  
end
