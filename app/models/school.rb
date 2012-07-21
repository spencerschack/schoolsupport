class School < ActiveRecord::Base

  using_access_control
  
  searches :name, :identifier

  attr_accessible :name, :period_ids, :student_ids, as: [:developer,
    :superintendent]
  attr_accessible :district_id, :user_ids, :identifier, :mascot_image, :city,
    :pdf_ids, as: [:developer]

  belongs_to :district
  has_many :users, dependent: :destroy, extend: WithTermExtension
  has_many :periods, dependent: :destroy, extend: WithTermExtension
  has_many :students, dependent: :destroy, extend: WithTermExtension
  has_many :tests, through: :students
  has_and_belongs_to_many :pdfs
  
  has_attached_file :mascot_image, path: '/school_mascots/:id/:basename_:style.:extension',
    styles: { thumbnail: '35x35^', original: ['', :png] }
  
  has_import identify_with: { identifier: nil }, associate: { district: :identifier }
  
  validates_presence_of :name, :district, :identifier
  validates_uniqueness_of :identifier
  
  def as_json options = {}
    { name: to_label, id: id, district_id: district_id }
  end
  
  def to_label
    "#{identifier} #{name}"
  end

end
