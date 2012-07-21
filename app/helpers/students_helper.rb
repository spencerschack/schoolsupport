module StudentsHelper
  
  PARENTS[:students] = [Period, User, School, District]
  
  FIELDS[:students] = {
    index: [:identifier, :name, :bus, :school],
    show: { fields: [:identifier, :grade, :bus_rfid, :dropped],
      relations: [:bus_route, :bus_stop, :tests, :periods, :users, :school, :district]},
    form: { fields: [:identifier, :first_name, :last_name, :grade,
      [:dropped, as: :radio], :image], relations: [[:school, as: :search_select],
      [:bus_stop, as: :search_select, depends_on: :district], [:bus_route,
        as: :search_select, depends_on: :district], [:periods, as: :token]] }
  }
  
end
