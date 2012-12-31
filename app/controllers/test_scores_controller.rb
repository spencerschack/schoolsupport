class TestScoresController < ApplicationController
  
  def find_collection
    @find_collection ||= begin
      default = super.joins(:student).order('students.last_name')
      if params[:grade].present? && params[:grade] != 'All'
        default = default.where('students.grade' => params[:grade])
      end
      if params[:test].present? && params[:test] != 'All'
        default = default.where('test_scores.test_name' => params[:test])
      end
      unless params[:term] == 'All' || params[:term].blank?
        default.where('test_scores.term' => params[:term])
      end
      @default_student_ids = default.limit(nil).offset(nil).pluck(:student_id)
      super(Student).where(id: @default_student_ids)
        .includes(:test_scores).order('students.last_name')
    end
  end
  
  def offset_amount
    50
  end
  
end
