module TestModelsHelper
  
  PARENTS[:test_models] = [TestGroup, District]
  
  FIELDS[:test_models] = {
    index: [:name, :test_group],
    show: { fields: [:name], relations: [:test_group, :test_attributes] },
    form: { fields: [:name], relations: [[:districts, as: :token], [:test_group, as: :search_select]] }
  }
  
end
