class Period < ActiveRecord::Base

  using_access_control
  
  attr_accessible :name, :student_ids, :user_ids, as: [:developer,
    :superintendent, :principal]
  attr_accessible :school_id, as: [:developer, :superintendent]
  attr_accessible :identifier, as: [:developer, :designer]

  belongs_to :school
  has_one :district, through: :school
  has_and_belongs_to_many :students
  has_and_belongs_to_many :users
  
  has_import identify_with: { identifier: :school_id,name: :school_id },
    associate: { school: :name }
    
  before_validation :set_school
  
  validates_presence_of :name, :school
  validates_uniqueness_of :name, scope: :school_id
  validates_uniqueness_of :identifier, scope: :school_id, allow_blank: true
  
  validate :students_in_school
  validate :users_in_school
  validate :school_in_district
  
  private
  
  # For principals that cannot edit school_id, add school for them.
  def set_school
    if !school_id && Authorization.current_user.respond_to?(:school_id)
      school_id = Authorization.current_user.school_id
    end
  end
  
  # If the students are not all in the same school as the period, then add an
  # error.
  def students_in_school
    if students.map(&:school_id).any?{|id| id != school_id }
      errors.add(:student_ids, 'must be in the same school as the period')
    end
  end
  
  # If ther users are not all in the same school as the period, then add an
  # error.
  def users_in_school
    if users.map(&:school_id).any?{|id| id != school_id }
      errors.add(:user_ids, 'must be in the same school as the period')
    end
  end
  
  # If the given school is not in the current user's scope of districts, then
  # add an error.
  def school_in_district
    if district && !permitted_to?(:show, object: district)
      errors.add(:school, 'must be in your district')
    end
  end
end
