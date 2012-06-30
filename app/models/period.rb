class Period < ActiveRecord::Base

  using_access_control
  
  attr_accessible :name, :student_ids, :user_ids, as: [:developer,
    :superintendent, :principal]
  attr_accessible :school_id, as: [:developer, :superintendent]

  belongs_to :school
  has_one :district, through: :school
  has_and_belongs_to_many :students
  has_and_belongs_to_many :users
  
  has_import format: :csv, identify_with: { name: :school_id },
    associate: { school: :name }
  
  validates_presence_of :name, :school
  validates_uniqueness_of :name, scope: :school_id
  
  validate :presence_of_school
  validate :students_in_school
  validate :users_in_school
  validate :school_in_district
  
  private
  
  # For principals that cannot edit school_id, add school for them.
  def presence_of_school
    school = Authorization.current_user.school unless school
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
    unless permitted_to? :show, object: school.district
      errors.add(:school, 'must be in your district')
    end
  end
end
