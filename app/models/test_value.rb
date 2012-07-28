class TestValue < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :test_attribute_id, :test_score_id, :value, as: [:developer,
    :superintendent, :principal, :teacher]
  
  belongs_to :test_score
  belongs_to :test_attribute
  
  validates_presence_of :test_attribute, :test_score
  validates_uniqueness_of :test_attribute_id, scope: [:test_score_id]
end
