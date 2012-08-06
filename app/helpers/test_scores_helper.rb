module TestScoresHelper
  
  PARENTS[:test_scores] = [TestModel, Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    show: { fields: [:term], relations: [:student, :test_model] }
  }
  
  def arranged_values test_scores
    ordered = Array.new(@column_total)
    test_scores.each do |score|
      index = @test_model_indices[score.test_model_id]
      ordered[index] = score.test_values.reject{|value| value.test_attribute.parent_id }
      score.test_values.each do |value|
        ordered[index += 1] = value
      end
    end
    ordered
  end
  
end
