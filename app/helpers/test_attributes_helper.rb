module TestAttributesHelper
  
  PARENTS[:test_attributes] = [TestModel, District]
  
  SORTS[:test_attributes] = {}
  
  FIELDS[:test_attributes] = {
    index: [:name, :parent, :test_model],
    show: { fields: [:name, :maximum_value, :advanced_proficient_boundary,
      :proficient_basic_boundary, :basic_below_basic_boundary,
      :below_basic_far_below_basic_boundary, :minimum_value], relations: [:test_model, :parent] },
    form: { fields: [:name, :maximum_value, :advanced_proficient_boundary,
        :proficient_basic_boundary, :basic_below_basic_boundary,
        :below_basic_far_below_basic_boundary, :minimum_value],
        relations: [[:test_model, as: :search_select], [:parent, as: :search_select, depends_on: :test_model, include_blank: true]] }
  }
  
end
