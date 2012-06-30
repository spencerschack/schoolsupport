class Font < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :name, :file, as: [:developer, :designer]
  
  has_many :fields
  
  has_attached_file :file, path: ':rails_root/public:url',
    url: '/fonts/:id/:basename.ttf'
  
  validates_presence_of :name
  validates_attachment :file, presence: true
  
  before_destroy :ensure_no_fields
  
  private
  
  def ensure_no_fields
    if fields.any?
      errors.add :base, 'Cannot be deleted. There are fields that use this font.'
    end
  end
end
