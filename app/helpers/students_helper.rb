module StudentsHelper
  
  PARENTS[:students] = [Period, User, School, District]
  
  SORTS[:students] = {
    name: 'students.last_name'
  }
  
  FIELDS[:students] = {
    index: [:identifier, :name, :grade, :teacher],
    show: { fields: [:identifier, :grade, :bus_rfid, :hispanic, :english_learner, :dropped],
      relations: [:bus_route, :bus_stop, :periods, :users, :school, :district]},
    form: { fields: [:identifier, :first_name, :last_name, :grade, :notes, [:hispanic, as: :radio], [:english_learner, as: :radio],
      [:dropped, as: :radio], :image], relations: [[:school, as: :search_select],
      [:bus_stop, as: :search_select, depends_on: :district], [:bus_route,
        as: :search_select, depends_on: :district], [:periods, as: :token,
          label: 'Classes', depends_on: :school]] }
  }
  
end
