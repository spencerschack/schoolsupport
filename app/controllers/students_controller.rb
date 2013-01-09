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
  
  def show
    @student_note = StudentNote.new
    @intervention = Intervention.new
  end
  
  def new_intervention
    @student = Student.find(params[:student_id])
    @intervention = @student.interventions.build(params[:intervention], as: current_role)
    success = @intervention.save
    render json: {
      success: success,
      page: render_to_string(success ? '_intervention_row' : '_intervention_form', layout: false)
    }
  end
  
  def new_student_note
    @student = Student.find(params[:student_id])
    @student_note = @student.student_notes.build(params[:student_note], as: current_role)
    @student_note.user_id = current_user.id
    success = @student_note.save
    render json: {
      success: success,
      page: render_to_string(success ? '_student_note_row' : '_student_note_form', layout: false)
    }
  end
  
  def destroy_intervention
    @intervention = Intervention.find(params[:intervention_id])
    @intervention.destroy
    render text: @intervention.destroyed?
  end
  
  def destroy_student_note
    @student_note = StudentNote.find(params[:student_note_id])
    @student_note.destroy
    render text: @student_note.destroyed?
  end

end
