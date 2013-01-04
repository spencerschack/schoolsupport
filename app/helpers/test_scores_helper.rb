module TestScoresHelper
  
  PARENTS[:test_scores] = [Student, Period, User, School, District]
  
  def data_columns
    TestScore.data_columns(force: true)
  end
  
  def score_columns
    @score_columns ||= begin
      score_columns = {}
      data_columns.each do |test_name, terms_and_keys|
        score_columns[test_name] ||= {}
        terms_and_keys.each do |term, keys|
          score_columns[test_name][term] = if keys.include?(test_name)
            [test_name] # If there is a key named the same as the test, return only that key.
          else
            keys.reject { |key| key =~ /_lv$|_rc/ } # Return all non level or report cluster keys.
          end
        end
      end
      score_columns
    end
  end
  
  def test_score_indices
    @test_score_indices ||= begin
      test_score_indices, index = {}, 0
      score_columns.each do |test_name, terms_and_keys|
        test_score_indices[test_name] = {}
        terms_and_keys.each_key do |term|
          test_score_indices[test_name][term] = index
          index += 1
        end
      end
      test_score_indices
    end
  end
  
  def ordered_test_scores test_scores
    array = []
    test_scores.each do |score|
      array[test_score_indices[score.test_name.downcase][score.term.downcase]] = score
    end
    array.each do |score|
      yield(score)
    end
  end
  
  def data_column_attributes test_name, term, key
    classes = ''
    if match = data_order_statement_regex.match(params[:order])
      classes << ' sorted'
      classes << ' reverse' if match[:direction] == 'desc'
      direction = match[:direction]
    else
      direction = 'asc'
    end
    order_statement = [test_name, term, key, direction].join(' ')
    %(data-order-by="#{order_statement}" class="replace double sortable#{classes}").html_safe
  end
  
end
