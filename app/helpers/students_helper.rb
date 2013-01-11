module StudentsHelper
  
  PARENTS[:students] = [Period, User, School, District]
  
  SORTS[:students] = {
    name: 'students.last_name',
    teacher: 'users.last_name'
  }
  
  FIELDS[:students] = {
    index: [:identifier, :name, :grade, :teacher],
    show: { fields: [:identifier, :grade, :hispanic, :english_learner, :dropped, :teacher],
      relations: [:periods, :users, :school, :district]},
    form: { fields: [:identifier, :first_name, :last_name, :grade, [:hispanic, as: :radio], [:english_learner, as: :radio],
      [:dropped, as: :radio], :image], relations: [[:school, as: :search_select],
      [:bus_stop, as: :search_select, depends_on: :district], [:bus_route,
        as: :search_select, depends_on: :district], [:periods, as: :token,
          label: 'Classes', depends_on: :school]] }
  }
  
  def sort_interventions interventions
    interventions.sort_by do |intervention|
      if %w(name start stop notes).map {|c| intervention.send(c) }.all?(&:blank?)
        Time.now
      else
        intervention.created_at
      end
    end
  end
  
  def format_holder_text text
    h(text).gsub(/\n/, '<br />').html_safe
  end
  
end
