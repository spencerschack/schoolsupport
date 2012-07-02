class School < ActiveRecord::Base

  using_access_control

  attr_accessible :name, :period_ids, :student_ids, as: [:developer,
    :superintendent]
  attr_accessible :district_id, :user_ids, :identifier, as: :developer
  attr_accessible :mascot_image, as: [:developer, :designer]

  belongs_to :district
  has_many :users
  has_many :periods
  has_many :students
  has_and_belongs_to_many :templates
  
  has_attached_file :mascot_image, path: ':rails_root/public:url',
    url: '/school_mascots/:id/:basename_:style.:extension',
    styles: { thumbnail: '35x35^', template: ['', :png] }
  
  has_import format: :csv, identify_with: { identifier: :district_id,
    name: :district_id }, associate: { district: :name }
  
  validates_presence_of :name, :district
  validates_uniqueness_of :name, :identifier, scope: :district_id 

end
