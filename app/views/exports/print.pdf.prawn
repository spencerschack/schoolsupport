# Pre-fetch all fonts, pdfs, and images.
@export.fetch_files

# Register fonts.
@export.pdf.fonts.each do |font|
  pdf.font_families.update(font.name => {
    normal: font.file.url
  })
end

require 'open-uri'

# Cache pdf.
@pdf = Thread.current[:export_files][@export.pdf.file.url]

@export.students.each do |student|

  pdf.start_new_page template: @pdf, margin: 0

  @export.pdf.fields.each do |field|
  
    # Handle image inserts.
    if Export.image_columns.include? field.column
      pdf.image Thread.current[:export_files][student.send(field.column).url],
        at: [field.x, field.y], width: field.width, height: field.height
    
    # Handle colors.
    elsif Export.color_columns.include? field.column
      pdf.fill_color student.send(field.column)
      pdf.fill_rectangle [field.x, field.y], field.width, field.height
    
    # Handle text inserts.
    else
      
      text = if field.column == 'prompt'
        @export.prompt_values[field.name] || ""
      else
        student.send(field.column)
      end
    
      pdf.font field.font.name
      pdf.fill_color field.color
      pdf.text_box text, at: [field.x, field.y], width: field.width,
        height: field.height, align: field.align.to_sym, size: field.text_size,
        overflow: :shrink_to_fit, character_spacing: field.spacing
    end
  
  end

end