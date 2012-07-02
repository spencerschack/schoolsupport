module PeriodsHelper
  
  PARENTS[:periods] = [Student, User, School]
  
  FIELDS[:periods] = {
    index: [:name, :school],
    show: [:name, :school, :students, :users],
    form: [:name, :school, :students, :users]
  }
  
  TYPES[:periods] = {
    students: :token,
    users: :token,
    school: :school
  }
  
end
