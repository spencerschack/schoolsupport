class District < ActiveRecord::Base

  using_access_control

  attr_accessible :school_ids, :name, :identifier, as: :developer

  has_many :schools, dependent: :destroy
  has_many :users, through: :schools
  has_many :students, through: :schools
  has_many :bus_stops, dependent: :destroy
  has_many :bus_routes, dependent: :destroy
  
  has_import identify_with: { identifier: nil }
  
  validates_presence_of :name
  validates_uniqueness_of :identifier
end
