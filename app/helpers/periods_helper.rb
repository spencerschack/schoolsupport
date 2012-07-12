module PeriodsHelper
  
  PARENTS[:periods] = [Student, User, School, District]
  
  FIELDS[:periods] = {
    index: [:name, :school],
    show: { fields: [:name], relations: [:school, :students, :users]},
    form: { fields: [:name], relations: [[:school, as: :school],
      [:students, as: :token], [:users, as: :token]] }
  }
  
end
