return if @export.errors.any?

# Register fonts.
@export.template.fonts.each do |font|
  pdf.font_families.update(font.name => {
    normal: font.file.url
  })
end

require 'open-uri'

# Cache template.
@template = open(@export.template.file.url)

@export.students.each do |student|

  pdf.start_new_page template: @template, margin: 0

  @export.template.fields.each do |field|
  
    # Handle image inserts.
    if Export.image_columns.include? field.column
      
      pdf.image open(student.send(field.column).url),
        at: [field.x, field.y], width: field.width, height: field.height
    
    # Handle colors.
    elsif Export.color_columns.include? field.column
      pdf.fill_color student.send(field.column)
      pdf.fill_rectangle [field.x, field.y], field.width, field.height
    
    # Handle text inserts.
    else
    
      pdf.font field.font.name
      pdf.fill_color field.color
      pdf.text_box student.send(field.column), at: [field.x, field.y],
        width: field.width, height: field.height, align: field.align.to_sym,
        overflow: :shrink_to_fit
    end
  
  end

end