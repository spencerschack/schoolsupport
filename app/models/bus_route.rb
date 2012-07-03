class BusRoute < ActiveRecord::Base
  
  attr_accessible :district_id, :color, :name, as: [:developer, :designer]
  
  belongs_to :district
  
  validates_presence_of :name, :district
  validates_uniqueness_of :name, scope: :district_id
  
  has_import identify_with: { name: :district_id },
    associate: { district: :name }
end
