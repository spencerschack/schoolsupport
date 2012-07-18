class Student < ActiveRecord::Base

  using_access_control
  
  default_scope where(dropped: false)

  attr_accessible :first_name, :grade, :last_name, as: [:developer,
    :superintendent, :principal, :teacher]
  attr_accessible :period_ids, :teacher, :teacher_last_year, :identifier,
    :dropped, as: [:developer, :superintendent, :principal]
  attr_accessible :school_id, as: [:developer, :superintendent]
  attr_accessible :image, :image_id, :bus_stop_id, :bus_route_id, :bus_rfid,
    as: [:developer, :designer]

  belongs_to :school
  belongs_to :bus_stop
  belongs_to :bus_route
  has_one :district, through: :school
  has_and_belongs_to_many :periods, conditions: proc { ['periods.term = ?', Period.current_term] }
  has_many :users, through: :periods
  
  has_attached_file :image,
    path: '/student_images/:image_id.:extension',
    styles: { original: ['', :png] }
  
  has_import identify_with: { identifier: nil }, associate: { school: :identifier,
    bus_route: :name, bus_stop: :name }
  
  before_validation :set_school
  
  validates_presence_of :first_name, :last_name, :grade, :identifier, :school
  validates_uniqueness_of :identifier
  validate :periods_in_school
  validate :school_in_district
  validate :bus_in_district
  
  # Returns comma separated last name first name.
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
  
  # Column for print jobs.
  def bus_stop_name
    bus_stop.try(:name)
  end
  
  # Column for print jobs.
  def bus_route_name
    bus_route.try(:name)
  end
  
  # Column for print jobs.
  def bus_route_color_value
    bus_route.try(:color_value)
  end
  
  # Used by Import to create a period to associate a user with a student.
  # All actions are taken with bangs to stop the import if unsuccessful.
  def set_teacher name, term
    user = User.find_by_name!(name)
    unless period = user.periods.first
      period = user.periods.build
      period.assign_attributes({
        name: Period.default_name_for(user),
        term: term,
        school_id: school_id
      }, as: mass_assignment_role)
      period.save!
    end
    periods << period
  end
  
  # Set the teacher for the previous term.
  def teacher_last_year= name
    set_teacher(name, Period.previous_term)
  end
  
  # Set the teacher for the current term.
  def teacher= name
    set_teacher(name, Period.current_term)
  end
  
  # Method for students index.html
  def bus
    [bus_route, bus_stop].map{|r| r.try(:name)}.compact.join(' / ')
  end
  
  # Which columns are available for templates.
  def self.template_column_options
    [
      ['Text', (column_names + %w(last_name_first_name first_name_last_name
        school_name bus_stop_name bus_route_name)).reduce([]) do |prev, curr|
        case curr
        when 'created_at', 'updated_at', 'id', /^image.+/, /_id$/
          prev
        else
          prev << [curr.titleize, curr]
        end
      end ],
      ['Image', [['Image', 'image'], ['School Mascot Image', 'school_mascot_image']]],
      ['Other', [['Bus Route Color Value', 'bus_route_color_value'], ['Prompt', 'prompt']]]
    ]
  end
  
  # The values of template_column_options.
  def self.template_columns
    template_column_options.reduce([]) do |prev, curr|
      prev + curr.last.map(&:last)
    end
  end
  
  # Drop the given ids.
  def self.drop_ids ids, options = {}
    find(ids).each do |record|
      record.update_attributes({ dropped: true }, as: options[:as])
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
