module FontsHelper
  
  FIELDS[:fonts] = {
    index: [:name],
    show: { fields: [:name, :file], relations: [:template] },
    form: { fields: [:name, [:file, hint: 'must be TrueType (.ttf)']],
      relations: [:template] }
  }
  
end
