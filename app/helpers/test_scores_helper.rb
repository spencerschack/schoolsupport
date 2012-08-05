module TestScoresHelper
  
  PARENTS[:test_scores] = [TestModel, Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    show: { fields: [:term], relations: [:student, :test_model] }
  }
  
  def ordered_scores test_scores
    ordered = Array.new(@test_models.length)
    test_scores.map do |test_score|
      ordered[@test_models[test_score.test_model]] = test_score
    end
    ordered
  end
  
  def ordered_test_values test_values
    grouped = test_values.group_by do |test_value|
      test_value.test_attribute.parent_id
    end
    ordered = []
    grouped[nil].each do |parent|
      ordered << parent
      if children = grouped[parent.test_attribute.id]
        ordered += children
      end
    end
    ordered
  end
  
  def test_value_classes_for test_value
    [test_value.level,
      test_value.test_attribute.parent_id ? 'child' : 'parent'
    ].join(' ')
  end
  
end
