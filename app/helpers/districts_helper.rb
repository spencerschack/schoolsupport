module DistrictsHelper
  
  FIELDS[:districts] = {
    index: [:name],
    show: [:name, :schools, :users, :students],
    form: [:name]
  }
  
end
