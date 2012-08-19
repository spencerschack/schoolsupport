module TestScoresHelper
  
  PARENTS[:test_scores] = [TestModel, Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    show: { fields: [:term], relations: [:student, :test_model] }
  }
  
  def calculate_positions collection
    collection.map do |student|
      x = x_value_for(student)
      y = y_value_for(student)
      next unless x && y
      [student, x, y]
    end.compact
  end
  
  def axis_labels range_or_cutoffs
    if (range = range_or_cutoffs).is_a?(Range)
      ary = range.begin.upto(range.end).to_a.in_groups(10, false).map(&:first)
      ary.map do |num|
        [num, position_for(num, range)]
      end
    elsif (cutoffs = range_or_cutoffs).is_a?(Hash)
      range = cutoffs[:far_below_basic]..cutoffs[:maximum]
      cutoffs.except(:maximum).map do |key, value|
        [key.to_s.humanize, position_for(value, range), key]
      end
    end.tap { |ary| ary[0][3] = true }
  end
  
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
  
  def group_name test_model
    if test_model.is_a?(TestModel)
      " data-group-name='#{test_model.test_group.name}'"
    end
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
  
  def arranged_scores scores
    scores.group_by do |score|
      score.test_model.test_group
    end.map do |group, scores|
      [group, scores.map do |score|
        [score, ordered_values(score.test_values)]
      end]
    end
  end
  
  private
  
  def ordered_values values
    grouped = values.group_by { |value| value.test_attribute.parent_id }
    ordered = []
    index = -1
    grouped[nil].sort_by(&:name).each do |parent|
      ordered[index += 1] = parent
      if children = grouped[parent.test_attribute_id]
        children.sort_by(&:name).each do |child|
          ordered[index += 1] = child
        end
      end
    end
    ordered
  end
  
  def x_value_for student
    range = if @x_axis_labels.is_a?(Range)
      @x_axis_labels
    else
      @x_axis_labels[:far_below_basic]..@x_axis_labels[:maximum]
    end
    if test_value = @test_values[@x_axis_id][student.id]
      position_for test_value.value, range
    end
  end
  
  def y_value_for student
    range = if @y_axis_labels.is_a?(Range)
      @y_axis_labels
    else
      @y_axis_labels[:far_below_basic]..@y_axis_labels[:maximum]
    end
    if test_value = @test_values[@y_axis_id][student.id]
      position_for test_value.value, range
    end
  end
  
  def position_for value, range
    (value - range.begin).to_f / (range.end - range.begin) * 100
  end
  
end
