module PdfsHelper
  
  PARENTS[:pdfs] = [Template]
  
  FIELDS[:pdfs] = {
    index: [:name, :template],
    show: { fields: [:name, :file], relations: [:template] },
    form: { fields: [:name, [:file, hint: 'must be a PDF']],
      relations: [:template, [:schools, as: :token]]}
  }
  
end
