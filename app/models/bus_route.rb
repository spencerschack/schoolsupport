class BusRoute < ActiveRecord::Base
  
  attr_accessible :district_id, :color_name, :color_value, :name,
    as: [:developer, :designer]
  
  belongs_to :district
  
  validates_presence_of :name, :district, :color_value
  validates_format_of :color_value, with: /#[0-9a-fA-F]{6}/
  validates_uniqueness_of :name, scope: :district_id
  
  has_import identify_with: { name: :district_id },
    associate: { district: :identifier }
end
