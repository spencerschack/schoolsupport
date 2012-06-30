module StudentsHelper
  
  PARENTS[:students] = [Period, User, School]
  
  FIELDS[:students] = {
    index: [:identifier, :first_name, :last_name, :school],
    show: [:identifier, :first_name, :last_name, :periods, :users, :school,
      :district, :grade, :am_bus_stop, :pm_bus_stop, :bus_pass_number],
    form: [:identifier, :first_name, :last_name, :grade, :am_bus_stop,
      :pm_bus_stop, :bus_pass_number, :school, :periods, :image]
  }
  
end
