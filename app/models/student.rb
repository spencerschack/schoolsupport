class Student < ActiveRecord::Base

  using_access_control

  attr_accessible :am_bus_stop, :bus_pass_number, :first_name, :grade,
    :last_name, :pm_bus_stop, as: [:developer, :superintendent, :principal,
    :teacher]
  attr_accessible :period_ids, :identifier, as: [:developer, :superintendent,
    :principal]
  attr_accessible :school_id, as: [:developer, :superintendent]
  attr_accessible :image, :image_file_name, :image_file_size,
    :image_content_type, :image_updated_at, as: :developer

  belongs_to :school
  has_one :district, through: :school
  has_and_belongs_to_many :periods
  has_many :users, through: :periods
  
  has_attached_file :image, path: ':rails_root/public:url',
    url: '/images/:hash.:extension',
    styles: { thumbnail: '35x35^', template: ['', :png] },
    hash_secret: 'jKVC1yzfL6pGnyWH8gQwUDUWAgyz8mp6AUU8KNZsyqDNDHMQ6rRRe6LYJQNlcvz'
  
  has_import identify_with: { identifier: nil }, associate: { school: :name },
    format: :csv
  
  before_validation :set_school
  
  validates_presence_of :first_name, :last_name, :grade, :identifier, :school
  validates_uniqueness_of :identifier
  validate :periods_in_school
  validate :school_in_district
  
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
  
  # Which columns are available for templates.
  def self.template_columns
    additional = %w(image last_name_first_name first_name_last_name)
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
end
