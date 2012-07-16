module UsersHelper
  
  PARENTS[:users] = [Student, Period, School, District]
  
  FIELDS[:users] = {
    index: [:name, :school, :role],
    show: { fields: [:email, :role],
      relations: [:district, :school, :periods, :students]},
    form: { fields: [:first_name, :last_name, :email, :password,
      :password_confirmation], relations: [[:school, as: :school],
      [:periods, as: :token], :role] }
  }

end
