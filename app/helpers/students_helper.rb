module StudentsHelper
  
  PARENTS[:students] = [Period, User, School]
  
  FIELDS[:students] = {
    index: [:identifier, :first_name, :last_name, :school],
    show: [:identifier, :first_name, :last_name, :periods, :users, :school,
      :district, :grade, :bus_route, :bus_stop, :bus_rfid],
    form: [:identifier, :first_name, :last_name, :grade, :school, :bus_stop,
      :bus_route, :bus_rfid, :periods, :image]
  }
  
  TYPES[:students] = {
    periods: :token,
    school: :school,
    bus_stop: :bus,
    bus_route: :bus
  }
  
end
