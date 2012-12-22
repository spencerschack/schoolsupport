class Setting < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :key, :value, as: :developer
  
  validates_presence_of :key, :value
  validates_uniqueness_of :key
  
  def self.value_of key
    where(key: key).first.try(:value)
  end
  
  def name
    key
  end
  
end
