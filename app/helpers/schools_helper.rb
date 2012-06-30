module SchoolsHelper
  
  PARENTS[:schools] = [Template]
  
  FIELDS[:schools] = {
    index: [:name, :district],
    show: [:name, :district, :users, :periods, :students],
    form: [:name, :district]
  }
  
end
