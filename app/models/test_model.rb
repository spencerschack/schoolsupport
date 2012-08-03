class TestModel < ActiveRecord::Base
  
  using_access_control
  
  searches :name
  
  attr_accessible :name, :district_ids, as: [:developer, :superintendent, :principal, :teacher]
  
  has_and_belongs_to_many :districts
  has_many :test_attributes, dependent: :destroy
  has_many :test_scores, dependent: :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
