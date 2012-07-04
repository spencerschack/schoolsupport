return if @export.errors.any?

# Register fonts.
@export.template.fonts.each do |font|
  pdf.font_families.update(font.name => {
    normal: font.file.path
  })
end

@export.students.each do |student|

  pdf.start_new_page template: @export.template.file.path, margin: 0

  @export.template.fields.each do |field|
  
    # Handle image inserts.
    if Export.image_columns.include? field.column
    
      pdf.image student.send(field.column).path(:template),
        at: [field.x, field.y], width: field.width, height: field.height
  
    # Handle text inserts.
    else
    
      pdf.font field.font.name
      pdf.text_box student.send(field.column), at: [field.x, field.y],
        width: field.width, height: field.height, align: field.align.to_sym,
        overflow: :shrink_to_fit
    end
  
  end

end