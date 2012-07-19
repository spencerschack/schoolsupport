class Template < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :name, :field_ids, as: [:developer, :designer]
  
  has_many :fields, dependent: :destroy
  has_many :fonts, through: :fields
  has_many :pdfs
  
  validates_presence_of :name
  
  def prompts
    fields.where(column: 'prompt')
  end
    
end
