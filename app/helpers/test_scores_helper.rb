module TestScoresHelper
  
  PARENTS[:test_scores] = [TestModel, Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    show: { fields: [:term], relations: [:student, :test_model] }
  }
  
  def arranged_attributes test_models
    ordered = Array.new(@column_total)
    test_models.each do |model|
      ordered[@test_model_indices[model.id]] = model
      model.test_attributes.each do |attribute|
        ordered[@test_attribute_indices[attribute.id]] = attribute
      end
    end
    ordered
  end
  
  def arranged_values test_scores
    ordered = Array.new(@column_total)
    test_scores.each do |score|
      parents = score.test_values.reject{|value| value.test_attribute.parent_id }
      ordered[@test_model_indices[score.test_model_id]] = parents
      score.test_values.each do |value|
        ordered[@test_attribute_indices[value.test_attribute_id]] = value
      end
    end
    ordered
  end
  
end
