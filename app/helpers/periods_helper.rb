module PeriodsHelper
  
  PARENTS[:periods] = [Student, User, School, District]
  
  FIELDS[:periods] = {
    index: [:name, :school],
    show: { fields: [:name, :term], relations: [:school, :students, :users]},
    form: { fields: [:name, [:term, collection: Period.term_choices]],
      relations: [[:school, as: :school], [:students, as: :token],
      [:users, as: :token]] }
  }
  
end
