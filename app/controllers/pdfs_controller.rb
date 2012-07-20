class PdfsController < ApplicationController
  
  def export
    if params[:student_select]
      identifiers = params[:student_select][:file].read.split("\n")
      students = Student.find_all_by_identifier(identifiers)
      params[:export_type] = 'print'
      params[:export_id] = params[:id]
      params[:selected] = { student_ids: students.map(&:id) }
      super
    end
  end

end
