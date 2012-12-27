class StudentsController < ApplicationController
  
  def export
    student_ids = collection.limit(nil).pluck(:id) - current_user.export_list_student_ids
    timestamp = "'#{Time.now.utc.to_s(:db)}'"
    values = student_ids.map do |id|
      %((#{timestamp},#{timestamp},#{id},#{current_user.id}))
    end.join(',')
    Student.connection.execute(%(INSERT INTO export_list_items ("created_at", "updated_at", "student_id", "user_id") VALUES #{values}))
    render json: export_list_count_and_styles
  end
  
  def find_collection
    default = super.includes(:users).order('students.last_name')
    return default if params[:term] == 'All' || params[:term].blank?
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] })
  end

end
