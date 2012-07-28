module PeriodsHelper
  
  PARENTS[:periods] = [Student, User, School, District]
  
  FIELDS[:periods] = {
    index: [:name, :school],
    show: { fields: [:name, :term], relations: [:school, :students, :users]},
    form: { fields: [:name, [:term, collection: Term.choices]],
      relations: [[:school, as: :search_select], [:students, as: :token],
      [:users, as: :token]] }
  }
  
end
