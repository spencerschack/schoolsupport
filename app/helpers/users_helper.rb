module UsersHelper
  
  PARENTS[:users] = [Student, Period, School]
  
  FIELDS[:users] = {
    index: [:first_name, :last_name, :district, :school, :role],
    show: [:first_name, :last_name, :email, :district, :school, :periods,
      :students, :role],
    form: [:first_name, :last_name, :email, :password, :password_confirmation,
      :school, :periods, :role]
  }

end
