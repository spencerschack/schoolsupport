module TestModelsHelper
  
  PARENTS[:test_models] = [District]
  
  FIELDS[:test_models] = {
    index: [:name],
    show: { fields: [:name], relations: [] },
    form: { fields: [:name], relations: [[:districts, as: :token]] }
  }
  
end
