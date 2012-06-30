class School < ActiveRecord::Base

  using_access_control

  attr_accessible :name, :period_ids, :student_ids, as: [:developer,
    :superintendent]
  attr_accessible :district_id, :user_ids, as: :developer

  belongs_to :district
  has_many :users
  has_many :periods
  has_many :students
  has_and_belongs_to_many :templates
  
  has_import format: :csv, identify_with: { name: :district_id },
    associate: { district: :name }
  
  validates_presence_of :name, :district
  validates_uniqueness_of :name, scope: :district_id

end
