module TestGroupsHelper
  
  PARENTS[:test_groups] = [District]
  
  SORTS[:test_groups] = {}
  
  FIELDS[:test_groups] = {
    index: [:name],
    show: { fields: [:name], relations: [:test_models] },
    form: { fields: [:name], relations: [[:test_models, as: :token], [:districts, as: :token]]}
  }
  
end
