class TestScoresController < ApplicationController
  
  filter_access_to :dynamic_fields_collection
  filter_access_to :dynamic_fields_member, attribute_check: true
  
  def index
    if find_first_parent.is_a?(Student)
      set_collection [find_first_parent]
    else
      scope = find_first_parent.students
        .includes(test_scores: { test_values: :test_attribute })
        
      if params[:term] != 'All' && Term.valid?(params[:term])
        scope = scope.where('test_scores.term' => params[:term] || Term.current)
      elsif params[:term] =~ /\d+/
        test_model_ids = TestModel.where(test_group_id: params[:term]).pluck(:id)
        if test_model_ids.any?
          scope = scope.where('test_scores.test_model_id' => test_model_ids)
        end
      end
      
      TestScore.without_dynamic_methods { set_collection scope.uniq.to_a }
      
      test_model_ids = collection.map(&:test_scores).flatten.map(&:test_model_id)
      @test_models = TestModel.where(id: test_model_ids)
        .includes(:test_group, :test_attributes)
      
      @test_model_indices = {}
      @cell_attributes = []
      @column_total = @test_models.reduce(0) do |index, model|
        length = index + model.test_attributes.length
        
        @cell_attributes[index] = "class=\"parent\" data-id=\"#{model.id}\"".html_safe
        child_attributes = "class=\"child\" data-parent-id=\"#{model.id}\"".html_safe
        @cell_attributes.fill(child_attributes, index + 1, length)
        
        @test_model_indices[model.id] = index
        length + 1
      end
    end
  end
  
  def dynamic_fields_collection
    set_resource new_resource
    dynamic_fields_member
  end
  
  def dynamic_fields_member
    @hide_fields = params[:test_model_id].blank?
    render '_dynamic_fields', layout: false
  end

end
