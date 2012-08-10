class TestScoresController < ApplicationController
  
  filter_access_to :dynamic_fields
  
  def index
    if find_first_parent.is_a?(Student)
      set_collection [find_first_parent]
    else
      scope = find_first_parent.students.includes(test_scores: { test_values: :test_attribute })
      
      if params[:test_model_ids].is_a?(Array)
        params[:test_model_ids].map!(&:to_i).uniq!
      else params[:term] != 'All' || find_first_parent.is_a?(Period)
        scope = scope.where('test_scores.term' => params[:term] || Term.current)
      end
      
      TestScore.without_dynamic_methods { set_collection scope.uniq.to_a }
      
      test_model_ids = if params[:test_model_ids].is_a?(Array)
        params[:test_model_ids]
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
  end
  
  def pie
    
  end
  
  def line
    
  end
  
  def dynamic_fields
    set_resource new_resource
    render '_dynamic_fields', layout: false
  end
  
  private
  
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
