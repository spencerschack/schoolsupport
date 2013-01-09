class StudentNote < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :notes, :student_id, :user_id, as:
    [:developer, :superintendent, :principal, :teacher]
  
  belongs_to :student
  belongs_to :user
  
  before_validation :set_user
  
  validates_presence_of :notes, :student, :user
  
  private
  
  def set_user
    if Authorization.current_user.respond_to?(:id)
      user = Authorization.current_user
    end
  end
  
end
