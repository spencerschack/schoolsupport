class Intervention < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :name, :notes, :start, :stop, :student_id, as: [:developer,
    :superintendent, :principal, :teacher]
  
  belongs_to :student
  
  validates_presence_of :name, :student
  
end
