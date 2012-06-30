module TemplatesHelper

  FIELDS[:templates] = {
    index: [:name],
    show: [:name, :file, :fields, :schools],
    form: [:name, :file, :schools]
  }
  
end
