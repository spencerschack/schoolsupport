class BusStop < ActiveRecord::Base
  
  include PgSearch
  
  pg_search_scope :search, :against => [:name],
    using: { tsearch: { prefix: true} }
  
  attr_accessible :district_id, :name, as: [:developer, :designer]
  
  belongs_to :district
  
  validates_presence_of :name, :district
  validates_uniqueness_of :name, scope: :district_id
  
  has_import identify_with: { name: :district_id },
    associate: { district: :identifier }
end
