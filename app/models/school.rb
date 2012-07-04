class School < ActiveRecord::Base

  using_access_control

  attr_accessible :name, :period_ids, :student_ids, as: [:developer,
    :superintendent]
  attr_accessible :district_id, :user_ids, :identifier, :mascot_image, :city,
    as: [:developer, :designer]

  belongs_to :district
  has_many :users, dependent: :destroy
  has_many :periods, dependent: :destroy
  has_many :students, dependent: :destroy
  has_and_belongs_to_many :templates
  
  has_attached_file :mascot_image, path: '/school_mascots/:id/:basename_:style.:extension',
    styles: { thumbnail: '35x35^', original: ['', :png] }
  
  has_import identify_with: { identifier: nil }, associate: { district: :name }
  
  validates_presence_of :name, :district, :identifier
  validates_uniqueness_of :identifier

end
