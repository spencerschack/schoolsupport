class TestAttribute < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :name, :test_model_id, as: [:developer, :superintendent,
    :principal, :teacher]
  
  belongs_to :test_model
  
  validates_presence_of :name, :test_model
end
