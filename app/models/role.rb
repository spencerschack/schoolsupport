class Role < ActiveRecord::Base

  using_access_control

  attr_accessible :name, :level

  has_many :users
  
  validates_presence_of :name
end
