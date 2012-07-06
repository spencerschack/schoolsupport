module TemplatesHelper

  FIELDS[:templates] = {
    index: [:name],
    show: [:name, :file, :fields, :schools],
    form: [:name, [:file, hint: 'must be a PDF'], [:schools, as: :token]]
  }
  
end
