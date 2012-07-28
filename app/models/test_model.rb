class TestModel < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :name, as: [:developer, :superintendent, :principal, :teacher]
  
  has_and_belongs_to_many :districts
  has_many :test_attributes
  has_many :test_scores
  
  validates_presence_of :name
end
