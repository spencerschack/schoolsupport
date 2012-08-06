class TestGroup < ActiveRecord::Base
  
  using_access_control
  
  searches :name
  
  attr_accessible :name, :district_ids, :test_model_ids, as: [:developer, :superintendent]
  
  has_and_belongs_to_many :districts
  has_many :test_models
  
  validates_presence_of :name
end
