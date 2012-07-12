module StudentsHelper
  
  PARENTS[:students] = [Period, User, School, District]
  
  FIELDS[:students] = {
    index: [:identifier, :name, :bus, :school],
    show: { fields: [:identifier, :grade, :bus_rfid, :dropped],
      relations: [:bus_route, :bus_stop, :periods, :users, :school, :district]},
    form: { fields: [:identifier, :first_name, :last_name, :grade,
      [:dropped, as: :radio], :image], relations: [[:school, as: :school],
      [:bus_stop, as: :bus], [:bus_route, as: :bus], [:periods, as: :token]] }
  }
  
end
