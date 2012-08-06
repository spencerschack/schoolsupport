class TestModel < ActiveRecord::Base
  
  using_access_control
  
  searches :name
  
  attr_accessible :name, :test_group_id, as: [:developer, :superintendent, :principal, :teacher]
  
  belongs_to :test_group
  has_many :test_attributes, dependent: :destroy
  has_many :test_scores, dependent: :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
