module ExportList
  
  def self.included base
    base.helper_method :export_list_styles, :student_select_class
  end
  
  def export_list_styles
    current_user.export_list_items.pluck(:student_id).map do |id|
      ".#{student_select_class(id)}"
    end.join(', ') <<
    " { background-position: 10px -2118px !important; }"
  end
  
  def student_select_class id
    "students-select-#{id}"
  end
  
  def export_list_count_and_styles
    {
      export_list_count: current_user.export_list_students.count,
      export_list_styles: export_list_styles
    }
  end
  
end