class District < ActiveRecord::Base

  using_access_control

  attr_accessible :school_ids, :name, as: :developer

  has_many :schools
  has_many :users, through: :schools
  has_many :students, through: :schools
  
  has_import identify_with: { name: nil }, format: :csv
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
