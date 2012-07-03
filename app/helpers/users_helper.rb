module UsersHelper
  
  PARENTS[:users] = [Student, Period, School, District]
  
  FIELDS[:users] = {
    index: [:first_name, :last_name, :district, :school, :role],
    show: [:first_name, :last_name, :email, :district, :school, :periods,
      :students, :role],
    form: [:first_name, :last_name, :email, :password, :password_confirmation,
      [:school, as: :school], [:periods, as: :token], :role]
  }

end
