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
    return default if params[:term] == 'All' || params[:term].blank?
    return default.with_no_period if params[:term] == 'With No Period'
    default.joins(:periods).where(periods: { term: params[:term] })
  end
  
  def new_intervention
    @student = Student.find(params[:student_id])
    @intervention = @student.interventions.build
    if params[:intervention]
      @intervention.assign_attributes(params[:intervention], as: current_role)
      @intervention.save
      respond_with @intervention
    end
  end
  
  def destroy_intervention
    @intervention = Intervention.find(params[:intervention_id])
    @intervention.destroy
    render text: @intervention.destroyed?
  end

end
