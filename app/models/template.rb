class Template < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :file, :name, :school_ids, :field_ids,
    as: [:developer, :designer]
  
  has_many :fields, dependent: :destroy
  has_many :fonts, through: :fields
  has_and_belongs_to_many :schools
  
  has_attached_file :file, path: ':rails_root/public:url',
    url: '/templates/:id/:basename_:style.:extension',
    styles: { thumbnail: ['35x35^', :png], small: ['70x70^', :png] }
  
  validates_presence_of :name
  validates_attachment :file, presence: true, content_type: {
    content_type: 'application/pdf' }
    
end
