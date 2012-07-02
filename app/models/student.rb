class Student < ActiveRecord::Base

  using_access_control

  attr_accessible :first_name, :grade, :last_name, as: [:developer,
    :superintendent, :principal, :teacher]
  attr_accessible :period_ids, :identifier, as: [:developer, :superintendent,
    :principal]
  attr_accessible :school_id, as: [:developer, :superintendent]
  attr_accessible :image, :bus_stop_id, :bus_route_id, :bus_rfid,
    as: [:developer, :designer]

  belongs_to :school
  belongs_to :bus_stop
  belongs_to :bus_route
  has_one :district, through: :school
  has_and_belongs_to_many :periods
  has_many :users, through: :periods
  
  has_attached_file :image, url: '', 
    path: ':rails_root/student_images/:id/:basename_:style.:extension',
    styles: { thumbnail: '35x35^', template: ['', :png] }
  
  has_import identify_with: { identifier: nil }, associate: { school: :name },
    format: :csv
  
  before_validation :set_school
  
  validates_presence_of :first_name, :last_name, :grade, :identifier, :school
  validates_uniqueness_of :identifier
  validate :periods_in_school
  validate :school_in_district
  validate :bus_in_district
  
  def name
    "#{last_name}, #{first_name}"
  end
  
  # Called by formtastic.
  def to_label
    "#{identifier} #{name}"
  end
  
  # Column for print jobs.
  def last_name_first_name
    "#{last_name}, #{first_name}"
  end

  # Column for print jobs.
  def first_name_last_name
    "#{first_name} #{last_name}"
  end

  # Column for print jobs.
  def school_name
    school.name
  end
  
  # Column for print jobs.
  def school_mascot_image
    school.mascot_image
  end
  
  # Which columns are available for templates.
  def self.template_columns
    additional = %w(image last_name_first_name first_name_last_name
      school_name school_mascot_image)
    (column_names + additional).reduce({}) do |prev, curr|
      case curr
      when 'created_at', 'updated_at', 'id', /^image.+/, /_id$/
        prev
      else
        prev.merge curr.titleize => curr
      end
    end
  end
  
  private
  
  # For principals that cannot edit school_id, add school for them.
  def set_school
    if !school_id && Authorization.current_user.respond_to?(:school_id)
      school_id = Authorization.current_user.school_id
    end
  end
  
  # If the periods are not in the specified school, then add an error.
  def periods_in_school
    if periods.map(&:school_id).any?{|id| id != school_id }
      errors.add(:periods, 'must be in the same school as the student')
    end
  end
  
  # If the given school is not in the current user's scope of districts, then
  # add an error.
  def school_in_district
    if school && !permitted_to?(:show, object: district)
      errors.add(:school, 'must be in your district')
    end
  end
  
  # Ensure the bus route and stop are in the same district as the student.
  def bus_in_district
    if bus_stop && bus_stop.district_id != district.id
      errors.add(:bus_stop, 'must be in the same district as the student')
    end
    if bus_route && bus_route.district_id != district.id
      errors.add(:bus_route, 'must be in the same district as the student')
    end
  end
end
