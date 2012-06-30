class Field < ActiveRecord::Base
  
  def self.align_options
    {
      'Left' => 'left',
      'Center' => 'center',
      'Right' => 'right'
    }
  end
  
  using_access_control
  
  attr_accessible :align, :column, :height, :template_id, :width, :x, :y,
    :font_id, :text_size, as: [:developer, :designer]
  
  belongs_to :template
  belongs_to :font
  
  validates_presence_of :column, :x, :y, :width, :height, :template, :font,
    :text_size
  validates_inclusion_of :column, in: Student.template_columns.values,
    message: 'is not a valid column'
  validates_inclusion_of :align, in: Field.align_options.values,
    message: 'is not a valid align setting'
  validates_numericality_of :x, :y, :width, :height, :text_size
  
  def name
    column.titleize
  end
  
end
