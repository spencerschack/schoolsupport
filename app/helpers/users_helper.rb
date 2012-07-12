module UsersHelper
  
  PARENTS[:users] = [Student, Period, School, District]
  
  FIELDS[:users] = {
    index: [:name, :district, :school, :role],
    show: [:email, :district, :school, :periods, :students, :role],
    form: [:first_name, :last_name, :email, :password, :password_confirmation,
      [:school, as: :school], [:periods, as: :token], :role]
  }

end
