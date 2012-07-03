module FieldsHelper
  
  PARENTS[:fields] = [Template]
  
  FIELDS[:fields] = {
    index: [:column, :template],
    show: [:column, :x, :y, :width, :height, :font, :text_size, :align,
      :template],
    form: [[:column, collection: Student.template_columns], :x, :y, :width,
      :height, :font, :text_size, [:align, collection: Field.align_options],
      :template]
  }
  
end
