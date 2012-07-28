module TestAttributesHelper
  
  PARENTS[:test_attributes] = [TestModel, District]
  
  FIELDS[:test_attributes] = {
    index: [:name, :test_model],
    show: { fields: [:name], relations: [:test_model] },
    form: { fields: [:name], relations: [:test_model] }
  }
  
end
