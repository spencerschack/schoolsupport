module TypesHelper
  
  PARENTS[:types] = [Pdf, Template]
  
  FIELDS[:types] = {
    index: [:name, :pdf],
    show: { fields: [:name], relations: [:pdf] },
    form: { fields: [:name], relations: [:pdf, [:schools, as: :token]] }
  }
  
end
