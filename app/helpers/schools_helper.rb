module SchoolsHelper
  
  PARENTS[:schools] = [Type, Pdf, Template, District]
  
  SORTS[:schools] = {
  }
  
  FIELDS[:schools] = {
    index: [:identifier, :name, :district],
    show: { fields: [:identifier, :name],
      relations: [:district, :users, :periods, :students, :test_scores] },
    form: { fields: [:identifier, :name, :mascot_image], relations: [:district] }
  }
  
end
