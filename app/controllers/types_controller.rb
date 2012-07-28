class TypesController < ApplicationController

  def export
    if params[:student_select]
      begin
        raise 'No file was uploaded.' unless params[:student_select][:file].respond_to?(:read)
        
        require 'csv'
        identifiers = CSV.parse(params[:student_select][:file].read).flatten
        students = Student.find_all_by_identifier(identifiers)
        raise 'No students could be found.' unless students.any?
        
        params[:export_type] = 'print'
        params[:export_id] = params[:id]
        params[:selected] = { student_ids: students.map(&:id) }
        
        super
      rescue => error
        @error = error.message
        render json: failure_hash
      end
    elsif params[:export]
      super
    end
  end

end
