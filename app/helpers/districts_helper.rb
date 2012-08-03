module DistrictsHelper
  
  FIELDS[:districts] = {
    index: [:identifier, :name],
    show: { fields: [:identifier, :name],
      relations: [:schools, :users, :students, :bus_routes, :bus_stops, :test_models, :test_scores]},
    form: { fields: [:identifier, :name, [:zpass, as: :radio]], relations: [[:test_models, as: :token]] }
  }
  
end
