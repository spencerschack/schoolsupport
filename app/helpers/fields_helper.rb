module FieldsHelper
  
  PARENTS[:fields] = [Template]
  
  FIELDS[:fields] = {
    index: [:column, :template],
    show: [:column, :x, :y, :width, :height, :font, :align, :template]
  }
  
end
