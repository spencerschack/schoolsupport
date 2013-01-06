class TestScoresController < ApplicationController
  
  helper_method :data_order_statement_regex
  
  def find_collection second = false
    @find_collection ||= begin
      
      # Pass super to Student so it uses that instead of the inferred model
      # TestScore from the controller_name. Outer join with test_scores to be
      # able to order and select by those fields.
      default = super(Student).includes(:test_scores)
      
      if params[:order].present? && match = data_order_statement_regex.match(params[:order])
        
        # Order by the comparison of test_name and term because the key in
        # data will not be unique across different years or tests.
        default = default.order(ActiveRecord::Base.send(:sanitize_sql, [
          "test_scores.test_name = :test_name asc, " +
          "test_scores.term = :term asc, " +
          "(test_scores.data -> :key) IS NULL asc, " +
          "(test_scores.data -> :key)::int #{match[:direction]}",
        {
          test_name: match[:test_name],
          term: match[:term],
          key: match[:key]
        }], 'test_scores'))
        
        @ordered = match
        
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
      default = default.order('students.last_name')
      
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
