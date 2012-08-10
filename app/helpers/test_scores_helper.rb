module TestScoresHelper
  
  PARENTS[:test_scores] = [TestModel, Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    show: { fields: [:term], relations: [:student, :test_model] }
  }
  
  def add_test_column_select
    if @unscoped_test_models.any?
      select_tag('add_test_column', test_column_options, prompt: 'Select a test to add...')
    else
      select_tag('add_test_column', '', prompt: 'All tests have been added.')
    end
  end
  
  def test_column_options
    grouped_options_for_select(@unscoped_test_models.group_by(&:test_group).map do |test_group, test_models|
      [test_group.name, test_models.map{|model| [model.name, model.id]}]
    end)
  end
  
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
      if index = @test_model_indices[score.test_model_id]
        ordered[index] = parents
        score.test_values.each do |value|
          ordered[@test_attribute_indices[value.test_attribute_id]] = value
        end
      end
    end
    ordered
  end
  
end
