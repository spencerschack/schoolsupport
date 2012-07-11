module FieldsHelper
  
  PARENTS[:fields] = [Template]
  
  FIELDS[:fields] = {
    index: [:column, :template],
    show: [:column, :x, :y, :width, :height, :font, :text_size, :color,
      :align, :template],
    form: [[:column, collection: Student.template_columns],
      [:x, hint: 'from the left'], [:y, hint: 'from the bottom'], :width,
      :height, :font, :text_size, :color,
      [:align, collection: Field.align_options], :template]
  }
  
end
