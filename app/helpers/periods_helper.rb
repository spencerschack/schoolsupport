module PeriodsHelper
  
  PARENTS[:periods] = [Student, User, School, District]
  
  FIELDS[:periods] = {
    index: [:name, :school],
    show: [:name, :school, :students, :users],
    form: [:name, [:school, as: :token], [:students, as: :token],
      [:users, as: :token]]
  }
  
end
