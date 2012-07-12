module SchoolsHelper
  
  PARENTS[:schools] = [Template, District]
  
  FIELDS[:schools] = {
    index: [:name, :district],
    show: { fields: [:name],
      relations: [:district, :users, :periods, :students] },
    form: { fields: [:identifier, :name, :mascot_image], relations: [:district] }
  }
  
end
