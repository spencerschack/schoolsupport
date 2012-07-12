module SchoolsHelper
  
  PARENTS[:schools] = [Template, District]
  
  FIELDS[:schools] = {
    index: [:identifier, :name, :district],
    show: { fields: [:identifier, :name],
      relations: [:district, :users, :periods, :students] },
    form: { fields: [:identifier, :name, :mascot_image], relations: [:district] }
  }
  
end
