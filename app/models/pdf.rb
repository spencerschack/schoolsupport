class Pdf < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :file, :school_ids, :name, :template_id, as: [:developer]
  
  has_and_belongs_to_many :schools
  belongs_to :template
  has_many :fields, through: :template
  has_many :fonts, through: :fields
  
  has_attached_file :file, path: '/pdfs/:id/:basename_:style.:extension',
    styles: { thumbnail: ['35x35^', :png] }
  
  validates_presence_of :name, :template
  validates_attachment :file, presence: true, content_type: {
    content_type: 'application/pdf' }
  
end
