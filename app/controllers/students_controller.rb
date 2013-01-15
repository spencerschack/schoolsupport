class StudentsController < ApplicationController
  
  def export
    student_ids = collection.limit(nil).pluck(:id) - current_user.export_list_student_ids
    insert_student_ids_into_export_list_items student_ids
    render json: export_list_count_and_styles
  end
  
  def find_collection
    default = super.includes(:users).order('students.last_name')
    if params[:grade].present? && params[:grade] != 'All'
      default = default.where(grade: params[:grade])
    end
    if params[:teacher].present? && params[:teacher] != 'All'
      default = default.joins(:periods).where('periods.id' => params[:teacher])
    end
    return default if params[:term] == 'All' || params[:term].blank?
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] })
  end
  
  def test_scores
    @student.initialize_interventions
  end

end
