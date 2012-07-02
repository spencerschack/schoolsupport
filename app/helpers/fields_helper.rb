module FieldsHelper
  
  PARENTS[:fields] = [Template]
  
  FIELDS[:fields] = {
    index: [:column, :template],
    show: [:column, :x, :y, :width, :height, :font, :text_size, :align,
      :template],
    form: [:column, :x, :y, :width, :height, :font, :text_size, :align,
      :template]
  }
  
  COLLECTIONS[:fields] = {
    column: Student.template_columns,
    align: Field.align_options
  }
  
  TYPES[:fields] = {
    column: :select,
    align: :select
  }
  
end
