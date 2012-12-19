module FontsHelper
  
  FIELDS[:fonts] = {
    index: [:name],
    show: { fields: [:name, :file] },
    form: { fields: [:name, [:file, hint: 'must be TrueType (.ttf)']] }
  }
  
end
