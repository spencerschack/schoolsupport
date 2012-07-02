if @print_job.errors.any?
  
  pdf.font_size 16
  pdf.text 'The print job failed because of the following errors.'
  pdf.move_down 10
  pdf.font_size 12
  
  @print_job.errors.full_messages.each do |error|
    pdf.text "#{error}."
  end
  
else

  # Register fonts.
  @print_job.template.fonts.each do |font|
    pdf.font_families.update(font.name => {
      normal: font.file.path
    })
  end

  @print_job.students.each do |student|
  
    pdf.start_new_page template: @print_job.template.file.path, margin: 0

    @print_job.template.fields.each do |field|
    
      # Handle image inserts.
      if PrintJob.image_columns.include? field.column
      
        pdf.image student.send(field.column).path(:template),
          at: [field.x, field.y], width: field.width, height: field.height
    
      # Handle text inserts.
      else
      
        pdf.font field.font.name
        pdf.text_box student.send(field.column), at: [field.x, field.y],
          width: field.width, height: field.height, align: field.align.to_sym
      end
    
    end
  
  end
  
end