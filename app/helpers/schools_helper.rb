module SchoolsHelper
  
  PARENTS[:schools] = [Template, District]
  
  FIELDS[:schools] = {
    index: [:name, :district],
    show: [:name, :district, :users, :periods, :students],
    form: [:identifier, :name, :district, :mascot_image]
  }
  
end
