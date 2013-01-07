module TestScoresHelper
  
  PARENTS[:test_scores] = [Student, Period, User, School, District]
  
  def group_levels students
    if @leveled
      students.group_by do |student|
        grouper = nil
        student.test_scores.each do |score|
          if @ordered && score.test_name.downcase == @ordered[:test_name] && score.term == @ordered[:term]
            grouper = score.data["#{@ordered[:key]}_lv"]
            break
          end
        end
        grouper || 'Unknown'
      end
    else
      [[nil, students]]
    end
  end
  
  def group_tests test_scores, &block
    hash = {}
    test_scores.each do |score|
      hash[score.test_name] ||= Array.new(2)
      hash[score.test_name][0] ||= SortedSet.new
      hash[score.test_name][0] += score.data.keys.reject do |key|
        key =~ /_lv$/
      end
      hash[score.test_name][1] ||= []
      hash[score.test_name][1] << score
    end
    hash
  end
  
  def data_columns
    @data_columns ||= begin
      Rails.cache.fetch("/test_scores/data_columns/#{data_columns_cache_key}") do
        data_columns = {}
      
        coll = TestScore.uniq.where({
          student_id: collection.limit(nil).offset(nil).select('students.id').to_a
        }).select('test_name, term, skeys(data)')
      
        coll = collection.where({
          term: params[:term]
        }) if params[:term].present? && params[:term] != 'All'
      
        coll = collection.where({
          test_name: params[:test_name]
        }) if params[:test_name].present? && params[:test_name] != 'All'
      
        TestScore.connection.execute(coll.to_sql).to_a.each do |score|
          test_name = score['test_name'].downcase
          term = score['term']
          data_columns[test_name] ||= {}
          data_columns[test_name][term] ||= Set.new
          data_columns[test_name][term] << score['skeys']
        end
        data_columns
      end
    end
  end
  
  def data_columns_cache_key
    sql = collection.joins('left outer join test_scores on students.id = test_scores.student_id')
      .group('test_scores.id, test_scores.updated_at')
      .limit(nil).offset(nil).reorder(nil)
      .select('test_scores.id, test_scores.updated_at').to_sql
    string = ActiveRecord::Base.connection.execute(sql).to_a.to_s
    Digest::SHA1.hexdigest(string)
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
            # Return all non level or report cluster keys.
            keys.reject do |key|
              
              # Check to see if the current ordered column is leveled.
              if @ordered && key == @ordered[:key] &&
                term == @ordered[:term] &&
                test_name == @ordered[:test_name]
                  @leveled = true if keys.include?("#{key}_lv")
              end
              key =~ /_lv$|_rc/
            end
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
      @test_score_count = index + 1
      test_score_indices
    end
  end
  
  def test_score_count
    @test_score_count || (test_score_indices && @test_score_count)
  end
  
  def ordered_test_scores test_scores, &block
    array = Array.new(test_score_count)
    test_scores.each do |score|
      array[test_score_indices[score.test_name.downcase][score.term.downcase]] = score
    end
    array.each(&block)
  end
  
  def associated_test_scores test_scores
    hash = {}
    test_scores.each do |score|
      hash[[score.test_name.downcase, score.term]] = score
    end
    yield(hash)
  end
  
  def data_column_attributes test_name, term, key
    classes = ''
    order_statement = [test_name, term, key].join(' ')
    if match = /#{order_statement} (?<direction>asc|desc)/.match(params[:order])
      classes << ' sorted'
      classes << ' reverse' if match[:direction] == 'desc'
    end
    %(data-order-by="#{order_statement}" class="replace double sortable#{classes}").html_safe
  end
  
end
