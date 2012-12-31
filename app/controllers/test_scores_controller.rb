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
  
  def find_collection
    @find_collection ||= begin
      
      # Pass super to Student so it uses that instead of the inferred model
      # TestScore from the controller_name. Outer join with test_scores to be
      # able to order and select by those fields.
      default = super(Student).includes(:test_scores)
      
      if params[:order].present? && match = data_order_statement_regex.match(params[:order])
        
        # Order by the comparison of test_name and term because the key in
        # data will not be unique across different years or tests.
        default = default.order(ActiveRecord::Base.send(:sanitize_sql, [%(
          test_scores.test_name = :test_name :direction,
          test_scores.term = :term :direction,
          test_scores.data -> ':key', :direction
        ), match], 'test_scores'))
      end
      
      if grade = option_filter_value(:grade)
        default = default.where('students.grade' => grade)
      end
      
      if test = option_filter_value(:test)
        default = default.where('test_scores.test_name' => test)
      end
      
      if term = option_filter_value(:term)
        default = default.where('test_scores.term' => term)
      end
      
      # Order by students last name after everything else so it does not
      # affect the overall order, but only when other order values are equal.
      default.order('students.last_name')
      
    end
  end
  
  # Set to a higher value because it takes longer to create the index html for
  # test scores.
  def offset_amount
    50
  end
  
  private
  
  # Return false if the parameter is not present or equal to 'All' or return
  # the parameter's value.
  def option_filter_value option
    params[option].present? && params[option] != 'All' && params[option]
  end
  
  # Tests order by values in the form:
  #   Cst 2012-2013 math asc
  def data_order_statement_regex
    /(?<test_name>.+) (?<term>\d{4}-\d{4}) (?<key>.+) (?<direction>asc|desc)/
  end
  
end
