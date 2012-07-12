module FontsHelper
  
  FIELDS[:fonts] = {
    index: [:name],
    show: { fields: [:name, :file], relations: [] },
    form: { fields: [:name, [:file, hint: 'must be TrueType (.ttf)']],
      relations: [] }
  }
  
end
