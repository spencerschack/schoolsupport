class Student < ActiveRecord::Base

  using_access_control
  
  default_scope where(dropped: false)
  
  scope :with_no_period, {
    joins:      'LEFT JOIN periods_students ON students.id = periods_students.student_id',
    conditions: 'periods_students.student_id IS NULL',
    select:     'DISTINCT students.*'
  }
  
  searches :first_name, :last_name, :identifier

  attr_accessible :first_name, :grade, :last_name, :image, :hispanic, :english_learner,
    as: [:developer, :superintendent, :principal, :teacher]
  attr_accessible :period_ids, :teacher, :teacher_last_year, :identifier,
    :dropped, as: [:developer, :superintendent, :principal]
  attr_accessible :school_id, as: [:developer, :superintendent]
  attr_accessible :image_file_name, :bus_stop_id, :bus_route_id,
    :bus_rfid, as: [:developer]

  belongs_to :school
  belongs_to :bus_stop
  belongs_to :bus_route
  has_one :district, through: :school
  has_and_belongs_to_many :periods, extend: WithTermExtension
  has_many :users, through: :periods, extend: WithTermExtension
  has_many :test_scores, dependent: :destroy
  has_many :export_list_items
  has_and_belongs_to_many :export_data
  
  has_attached_file :image,
    path: '/student_images/:basename:style_unless_original.:extension',
    styles: {
      original: ['', :jpg],
      thumbnail: ['70x70', :jpg],
      index: ['35x35', :jpg]
    }
  
  has_import identify_with: { identifier: :school_id }, associate: { school: :identifier,
    bus_route: :name, bus_stop: :name },
    prompts: proc { [[:school, collection: School.with_permissions_to(:show).order('name')]] }
  
  before_validation :set_school
  
  validates_presence_of :first_name, :last_name, :grade, :identifier, :school
  validates_uniqueness_of :identifier, scope: :school_id
  validate :periods_in_school
  validate :bus_in_district

  def as_json options = {}
    super(options.reverse_merge(only: [:id, :name, :identifier]))
  end
  
  # Never overwrite image_file_name with a blank value.
  def image_file_name= value
    super if value.present?
  end
  
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
  
  # Column for print jobs.
  def barcode
    "*#{identifier}*"
  end
  
  # Column for print jobs.
  def grade_with_label
    "Grade: #{grade}"
  end
  
  # Column for print jobs.
  def image_if_present
    image? ? image : nil
  end
  
  # Used by Import to create a period to associate a user with a student.
  # All actions are taken with bangs to stop the import if unsuccessful.
  def set_teacher name, term
    user = User.where(school_id: school_id).find_by_name!(name)
    if period = user.periods.first
      periods << period unless periods.include? period
    else
      period = Period.new({
        name: Period.default_name_for(user),
        term: term,
        school_id: school_id,
        user_ids: [user.id]
      }, as: mass_assignment_role)
      period.save!
      periods << period
    end
  end
  
  # Set the teacher for the previous term.
  def teacher_last_year= name
    set_teacher(name, Period.previous_term)
  end
  
  # Set the teacher for the current term.
  def teacher= name
    set_teacher(name, Term.current)
  end
  
  # Return first user
  def teacher
    users.first
  end
  
  # Method for students index.html
  def bus
    [bus_route, bus_stop].map{|r| r.try(:name)}.compact.join(' / ')
  end
  
  # Options with titleized labels.
  def self.sort_options
    sorts.map { |option| [option.titleize, option] }
  end
  
  def self.default_columns
    @default_columns ||= column_names.reject do |column|
      case column; when 'created_at', 'updated_at', 'id', /^image.+/, /_id$/; true end
    end
  end
  
  # Which columns can be sorted on during export.
  def self.sorts
    ['teacher'] + default_columns
  end
  
  # Which columns are available for templates.
  def self.template_column_options
    [
      ['Student', (default_columns + %w(grade_with_label last_name_first_name first_name_last_name image image_if_present))],
      ['School', %w(school_mascot_image school_name)],
      ['Bus', %w(bus_route_name bus_stop_name bus_route_color_value)],
      ['Other', %w(type barcode prompt)]
    ].map do |(group, options)|
      [group, options.map { |option| [option.titleize, option] } ]
    end
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
      write_attribute(:school_id, Authorization.current_user.school_id)
    end
  end
  
  # If the periods are not in the specified school, then add an error.
  def periods_in_school
    if periods.map(&:school_id).any?{|id| id != school_id }
      errors.add(:periods, 'must be in the same school as the student')
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
