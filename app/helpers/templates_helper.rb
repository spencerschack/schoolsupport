module TemplatesHelper

  FIELDS[:templates] = {
    index: [:name],
    show: { fields: [:name, :file], relations: [:fields, :schools] },
    form: { fields: [:name, [:file, hint: 'must be a PDF']],
      relations: [[:schools, as: :token]] }
  }
  
end
