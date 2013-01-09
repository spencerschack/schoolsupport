module TestScoresHelper
  
  PARENTS[:test_scores] = [Student, Period, User, School, District]
  
  def group_levels students
    if @leveled
      students.group_by do |student|
        grouper = nil
        student.test_scores.each do |score|
          if @ordered && score.test_name == @ordered[:test_name] && score.term == @ordered[:term]
            grouper = score.data[level_column_for(@ordered[:key])]
            break
          end
        end
        grouper.present? ? grouper : 'unknown'
      end
    else
      [[nil, students]]
    end
  end
  
  def group_tests test_scores
    hash = {}
    grouped = test_scores.group_by(&:test_name)
    grouped.each do |test_name, test_scores|
      hash[test_name] = {}
      test_scores.sort_by(&:term).each_with_index do |score, index|
        score.data.each do |key, value|
          if !level_column?(key) && (index.zero? || key !~ /_rc/)
            hash[test_name]["#{key.titleize} #{Term.shorten(score.term)}"] = {
              level: score.data[level_column_for(key)],
              score: value
            }
          end
        end
      end
    end
    hash
  end
  
  def data_columns options = {}
    @data_columns ||= begin
      Rails.cache.fetch("/test_scores/data_columns/#{data_columns_cache_key}", options) do
        data_columns = {}
        
        coll = find_collection(true)
          .limit(nil).offset(nil)
          .select('students.id')
        
        coll = TestScore.uniq.where({
          student_id: coll
        }).select('test_name, term, skeys(data)')
      
        coll = coll.where({
          term: params[:term]
        }) if params[:term].present? && params[:term] != 'All'
      
        coll = coll.where({
          test_name: params[:test_name]
        }) if params[:test_name].present? && params[:test_name] != 'All'
      
        TestScore.connection.execute(coll.to_sql).to_a.each do |score|
          test_name = score['test_name']
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
    sql = find_collection(true)
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
        
        next if @selected_test && test_name != @selected_test
        
        score_columns[test_name] ||= {}
        terms_and_keys.each do |term, keys|
          
          next if @selected_term && term != @selected_term
          
          # If there is a key named the same as the test, return only that key.
          # Set @leveled to whether the data is ordered by that single key.
          score_columns[test_name][term] = if key = keys.grep(/^#{test_name}$/i).first
            if matches_current_order(test_name, term, key) && keys.include?(level_column_for(key))
              @leveled = true
            end
            [key]
            
          else
            
            # Return all non level or report cluster keys.
            keys.reject do |key|
              
              # Check to see if the current ordered column is leveled.
              if matches_current_order(test_name, term, key) && keys.include?(level_column_for(key))
                @leveled = true
              end
              level_column?(key) || key =~ /_rc/
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
  
  def associated_test_scores test_scores
    hash = {}
    test_scores.each do |score|
      hash[[score.test_name, score.term]] = score
    end
    yield(hash)
  end
  
  def data_column_attributes test_name, term, key
    classes = ''
    if matches_current_order(test_name, term, key)
      classes << ' sorted'
      classes << ' reverse' if @ordered[:direction] == 'desc'
    end
    
    # Sort by level if we can.
    if data_columns[test_name][term].include?(level_column_for(key))
      key = level_column_for(key)
    end
    
    %(data-order-by="#{[test_name, term, key].join(' ')}" class="replace sortable small#{classes}").html_safe
  end
  
  def matches_current_order test_name, term, key
    @ordered && test_name == @ordered[:test_name] &&
      term == @ordered[:term] && key == score_column_for(@ordered[:key])
  end
  
end
