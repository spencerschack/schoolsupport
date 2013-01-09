class TestScoresController < ApplicationController
  
  helper_method :data_order_statement_regex, :level_column_for, :score_column_for, :level_column?
  
  def find_collection without = false
    # Pass super to Student so it uses that instead of the inferred model
    # TestScore from the controller_name. Outer join with test_scores to be
    # able to order and select by those fields. Preload must be called
    # instead of includes or eager_load because rails must load the students
    # and then load the test_scores in another query for the last statement
    # in this method to work properly, otherwise only the ordered by test
    # score will be loaded.
    default = super(Student).preload(:test_scores).preload(:users)
      .joins('LEFT OUTER JOIN test_scores ON students.id = test_scores.student_id')
      .joins('LEFT OUTER JOIN periods_students ON students.id = periods_students.student_id')
      .joins('LEFT OUTER JOIN periods ON periods_students.period_id = periods.id')
      .joins('LEFT OUTER JOIN periods_users ON periods.id = periods_users.period_id')
      .joins('LEFT OUTER JOIN users ON periods_users.user_id = users.id')
    
    # Used by some methods to calculate the present columns so the where and
    # order clauses are not necessary.
    return default if without
    
    @selected_test = false
    @selected_term = false
    
    if grade = option_filter_value(:grade)
      default = default.where('students.grade' => grade)
    end

    if test = option_filter_value(:test)
      default = default.where('test_scores.test_name' => test)
      @selected_test = test
    end

    if term = option_filter_value(:term)
      default = default.where('test_scores.term' => term)
      @selected_term = term
    end
    
    if params[:order].present? && order_match = data_order_statement_regex.match(params[:order])
      
      # Skip ordering if the term or test filter does not align with the
      # ordered column, otherwise no rows will match. Also nillify order_match
      # so all other code thinks there is no order.
      if (@selected_test && @selected_test != order_match[:test_name]) ||
        (@selected_term && @selected_term != order_match[:term])
          order_match = nil
      else
        
        # If ordering by a level, create an order statement to order by
        # adv, prof, basic, bbasic, fbb or the opposite.
        level_order_statement = if level_column?(order_match[:key])
          
          # Make sure to duplicate levels otherwise reverse will cause the
          # direction to be wrong every other time this method is called.
          levels = TestScore.levels
          levels.reverse! if order_match[:direction] == 'desc'
          
          levels.reduce('') do |statement, level|
            statement << "(test_scores.data -> :key) = '#{level}', "
          end
        end
      
        # Order by the comparison of test_name and term because the key in
        # data will not be unique across different years or tests. Order by
        # is the value for the given key is NULL or '' so useful data always
        # appears at the top.
        default = default.order(ActiveRecord::Base.send(:sanitize_sql, [
          "test_scores.test_name = :test_name, " +
          "test_scores.term = :term, " +
          "((test_scores.data -> :key) IS NULL OR" +
          " (test_scores.data -> :key) = ''), " +
          (level_order_statement || '') +
          "lpad(test_scores.data -> :score_key, 10, '0') #{order_match[:direction]}",
        {
          test_name: order_match[:test_name],
          term: order_match[:term],
          score_key: score_column_for(order_match[:key]),
          key: order_match[:key]
        }], 'test_scores'))
      
        @ordered = order_match
      end
    end
    
    # Order by students last name after everything else so it does not
    # affect the overall order, but only when other order values are equal.
    default = default.order('students.last_name')
    
    # No join restriction is needed if the data is not ordered. Uniq is only
    # present here because duplicates are handled by the join restriction
    # below and uniq breaks the code below if included beforehand.
    if order_match
    
      # Restrict the join to only one row when ordering by a test_score
      # otherwise the query will return a student for each test_score row.
      default.where(%((test_scores.id IN (#{
        TestScore.select('MAX(test_scores.id)')
        .where('test_scores.test_name' => order_match[:test_name])
        .group('test_scores.student_id').to_sql
      }) OR test_scores.id IS NULL)))
    else
      
      # Add order values to select because for DISTINCT, postgres requires
      # all values in ORDER BY to also be present in the SELECT clause.
      order_values = default.order_values.join(', ').gsub(/ (asc|desc)/, '')
      default.uniq.select('students.*').select(order_values)
    end
  end
  
  # Method called by declarative authorization to authorize the current user
  # to load the show action. The actual record this page represents is a
  # student, but declarative authorization expects a test score so send it
  # one. Must override this method and not simply define "load_test_score"
  # because the filter_access_to is called from ApplicationController so
  # controller_name is "application", so declarative authorization calls
  # "load_application".
  def load_controller_object context
    @student ||= begin
      id = params[find_first_parent.is_a?(Student) ? :student_id : :id ]
      Student.find(id)
    end
    @test_score = TestScore.new({student_id: @student.id}, as: current_role)
  end
  
  def show
    @student ||= Student.find(params[:student_id])
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
  # The ^ and $ anchors are very important for protection against sql
  # injection attacks.
  def data_order_statement_regex
    /^(?<test_name>.+) (?<term>\d{4}-\d{4}) (?<key>.+) (?<direction>asc|desc)$/
  end
  
  # Convert column to level column
  def level_column_for column
    level_column?(column) ? column : "#{column}lv"
  end
  
  # Convert column to score column
  def score_column_for column
    (match = level_column?(column)) ? match[:score_column] : column
  end
  
  # Test whether the column is a level column.
  def level_column? column
    /(?<score_column>.+)lv$/.match(column)
  end
  
end
