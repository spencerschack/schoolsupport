module FontsHelper
  
  FIELDS[:fonts] = {
    index: [:name],
    show: [:name, :file],
    form: [:name, [:file, hint: 'must be TrueType (.ttf)']]
  }
  
end
