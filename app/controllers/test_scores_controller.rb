class TestScoresController < ApplicationController
  
  filter_access_to :dynamic_fields_collection
  filter_access_to :dynamic_fields_member, attribute_check: true
  
  def index
    @test_models = Hash[find_first_parent.test_models.uniq.each_with_index.to_a]
    if find_first_parent.is_a?(Student)
      set_collection [find_first_parent]
    else
      scope = find_first_parent.students.includes(test_scores: [:test_model, :test_values])
      if params[:term] != 'All'
        scope = scope.where('test_scores.term' => params[:term] || Term.current)
      end
      set_collection scope.uniq
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
