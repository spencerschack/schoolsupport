module StudentsHelper
  
  PARENTS[:students] = [Period, User, School, District]
  
  FIELDS[:students] = {
    index: [:identifier, :first_name, :last_name, :school],
    show: [:identifier, :first_name, :last_name, :periods, :users, :school,
      :district, :grade, :bus_route, :bus_stop, :bus_rfid],
    form: [:identifier, :first_name, :last_name, :grade,
      [:school, as: :school], [:bus_stop, as: :bus], [:bus_route, as: :bus],
      :bus_rfid, [:periods, as: :token], :image]
  }
  
end
