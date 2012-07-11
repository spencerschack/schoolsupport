module FieldsHelper
  
  PARENTS[:fields] = [Template]
  
  FIELDS[:fields] = {
    index: [:name, :column, :template],
    show: [:name, :column, :x, :y, :width, :height, :font, :text_size, :color,
      :align, :spacing, :template],
    form: [:name, [:column, collection: Student.template_column_options],
      [:x, hint: 'from the left'], [:y, hint: 'from the bottom'], :width,
      :height, :font, :text_size, :color,
      [:align, collection: Field.align_options], :spacing, :template]
  }
  
end
