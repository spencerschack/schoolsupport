class TestScoresController < ApplicationController
  
  filter_access_to :dynamic_fields, :student, :compare
  
  def index
    scope = find_first_parent.students.includes(test_scores: { test_values: :test_attribute })
    
    TestScore.without_dynamic_methods { set_collection scope.uniq.to_a }
    
    test_model_ids = if params[:test_model_ids].is_a?(Array)
      params[:test_model_ids].map!(&:to_i).uniq!
    else
      collection.map(&:test_scores).flatten.map(&:test_model_id).uniq
    end
    
    @test_models, @unscoped_test_models = [], []
    find_first_parent.test_models.includes(:test_group, :test_attributes).uniq.each do |test_model|
      if test_model_ids.include?(test_model.id)
        @test_models << test_model
      else
        @unscoped_test_models << test_model
      end
    end
    
    @test_model_indices = {}
    @test_attribute_indices = {}
    @cell_attributes = []
    @column_total = ordered_models(@test_models).reduce(0) do |index, model|
      @test_model_indices[model.id] = index
      @cell_attributes[index] = "class=\"parent\" data-id=\"#{model.id}\"".html_safe
      ordered_attributes(model.test_attributes).each do |attribute|
        @test_attribute_indices[attribute.id] = (index += 1)
        @cell_attributes[index] = "class=\"child\" data-parent-id=\"#{model.id}\"".html_safe
        @cell_attributes[index][11] += ' overall' unless attribute.parent_id?
        @cell_attributes[index] += ' data-leveled=true' if attribute.leveled?
      end
      index + 1
    end
    
    if params[:test_model_ids]
      render json: {
        headers: render_to_string('headers', layout: false),
        rows: collection.map do |student|
          {
            id: student.id,
            cells: render_to_string('cells', locals: { student: student }, layout: false)
          }
        end
      }
    end
  end
  
  def compare
    scope = find_first_parent.students.includes(test_scores: [
      { test_values: :test_attribute }, { test_model: :test_attributes } ])
    TestScore.without_dynamic_methods { set_collection scope.to_a }
    
    @x_axis_id = params[:x_axis].try(:to_i)
    @y_axis_id = params[:y_axis].try(:to_i)
    @test_values = {}
    
    test_attributes = collection.map do |student|
      student.test_scores.map do |score|
        score.test_values.each do |value|
          @test_values[value.test_attribute_id] ||= {}
          @test_values[value.test_attribute_id][student.id] = value
        end
        score.test_model
      end
    end.flatten.uniq.map do |model|
      [model.name, ordered_attributes(model.test_attributes).map do |attribute|
        if @x_axis_id == attribute.id || !@x_axis_id
          @x_axis_id = attribute.id  
          @x_axis_method = attribute.name
        end
        if @y_axis_id == attribute.id || (!@y_axis_id && @x_axis_id != attribute.id)
          @y_axis_id = attribute.id
          @y_axis_method = attribute.name
        end
        [attribute.name, attribute.id]
      end]
    end
    
    # Break unless there are valid columns to compare
    unless @x_axis_id && @y_axis_id
      return render
    end
    
    x_values = @test_values[@x_axis_id].values
    @x_axis_labels = if x_values.first.leveled?
      cutoffs_for(x_values.first)
    else
      x_values.map!(&:value)
      x_min = x_values.min
      x_max = x_values.max
      x_margin = [(x_max - x_min), 50].max / 10
      x_min -= x_margin
      x_max += x_margin
      x_min.floor..x_max.ceil
    end
    
    y_values = @test_values[@y_axis_id].values
    @y_axis_labels = if y_values.first.leveled?
      cutoffs_for(y_values.first)
    else
      y_values.map!(&:value)
      y_min = y_values.min
      y_max = y_values.max
      y_margin = [(y_max - y_min), 50].max / 10
      y_min -= y_margin
      y_max += y_margin
      y_min.floor..y_max.ceil
    end
    
    @x_axis_options = test_attributes
    @y_axis_options = test_attributes
  end
  
  def dynamic_fields
    set_resource new_resource
    render '_dynamic_fields', layout: false
  end
  
  def student
    @student = Student.includes(:users, :school, test_scores: [
      { test_values: :test_attribute }, { test_model: :test_group }
    ]).find(params[:student_id])
  end
  
  private
  
  def cutoffs_for attribute
    {
      far_below_basic: attribute.minimum_value,
      below_basic: attribute.below_basic_far_below_basic_boundary,
      basic: attribute.basic_below_basic_boundary,
      proficient: attribute.proficient_basic_boundary,
      advanced: attribute.advanced_proficient_boundary,
      maximum: attribute.maximum_value
    }
  end
  
  def ordered_models test_models
    if params[:test_model_ids]
      ordered = []
      indices = Hash[params[:test_model_ids].each_with_index.to_a]
      test_models.each do |test_model|
        ordered[indices[test_model.id]] = test_model
      end
      ordered
    else
      test_models
    end
  end
  
  def ordered_attributes test_attributes
    grouped = test_attributes.group_by(&:parent_id)
    ordered = Array.new(test_attributes.length)
    index = -1
    grouped[nil].sort_by(&:name).each do |parent_attribute|
      ordered[index += 1] = parent_attribute
      if children = grouped[parent_attribute.id]
        children.sort_by(&:name).each do |child_attribute|
          ordered[index += 1] = child_attribute
        end
      end
    end
    ordered
  end

end
