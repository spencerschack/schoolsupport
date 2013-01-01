module TestScoresHelper
  
  PARENTS[:test_scores] = [Student, Period, User, School, District]
  
  def data_columns
    TestScore.data_columns(force: true)
  end
  
  def score_columns
    @score_columns ||= begin
      score_columns = {}
      data_columns.each do |test_name_and_term, keys|
        score_columns[test_name_and_term] = keys.reject do |key|
          key =~ /_lv$|_rc/
        end
      end
      score_columns
    end
  end
  
  def test_score_indices
    @test_score_indices ||= Hash[data_columns.keys.each_with_index.to_a]
  end
  
  def ordered_test_scores test_scores
    array = Array.new(test_scores.length)
    test_scores.each do |score|
      begin
        array[test_score_indices[score.name]] = score
      rescue
        Rails.logger.debug "OFFENDING: #{score.name}"
      end
    end
    array.each do |score|
      yield(score)
    end
  end
  
  def data_column_attributes key
    classes = ''
    if params[:order] =~ /-> '#{key}'/
      classes << ' sorted'
      classes << ' reverse' if params[:order] =~ /desc$/
    end
    %(data-order-by="(test_scores.data -> '#{key}')::int" class="replace double sortable#{classes}").html_safe
  end
  
end
