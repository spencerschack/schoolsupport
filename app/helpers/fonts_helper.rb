module FontsHelper
  
  FIELDS[:fonts] = {
    index: [:name],
    show: [:name, :file],
    form: [:name, :file],
  }
  
end
