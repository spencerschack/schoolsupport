class School < ActiveRecord::Base

  using_access_control
  
  searches :name, :identifier

  attr_accessible :name, :period_ids, :student_ids, as: [:developer,
    :superintendent]
  attr_accessible :district_id, :user_ids, :identifier, :mascot_image, :city,
    :type_ids, as: [:developer]

  belongs_to :district
  has_many :users, dependent: :destroy, extend: WithTermExtension
  has_many :periods, dependent: :destroy, extend: WithTermExtension
  has_many :students, dependent: :destroy, extend: WithTermExtension
  has_many :test_scores, through: :students
  has_many :test_models, through: :test_scores
  has_and_belongs_to_many :types
  
  has_attached_file :mascot_image, path: '/school_mascots/:id/:basename_:style.:extension',
    styles: { thumbnail: '35x35^', original: ['', :png] }
  
  has_import identify_with: { identifier: nil }, associate: { district: :identifier }
  
  validates_presence_of :name, :district, :identifier
  validates_uniqueness_of :identifier
  
  def as_json options = {}
    super(options.reverse_merge(only: [:id, :district_id])).reverse_merge(name: to_label)
  end
  
  def to_label
    "#{identifier} #{name}"
  end

end
