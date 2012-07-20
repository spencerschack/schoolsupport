class Export < Tableless
  
  # Return whether the given model or record is capable of having an export.
  def self.for? model_or_record
    return true if model_or_record.is_a?(Pdf)
    model_or_record = model_or_record.class unless model_or_record.is_a?(Class)
    model_or_record == Student || !!model_or_record.reflect_on_association(:students)
  end
  
  # What types are accepted.
  def self.types
    %w(print zpass)
  end
  
  # What template columns are images.
  def self.image_columns
    %w(image school_mascot_image)
  end
  
  # What template columns are colors.
  def self.color_columns
    %w(bus_route_color_value)
  end
  
  column :pdf_id, :integer
  
  attr_accessor :type, :prompt_values
  
  attr_accessible :students, :student_ids, :pdf_id, :period_ids,
    :user_ids, :type, :prompt_values, as: [:developer, :designer,
    :superintendent, :principal, :teacher]
  attr_accessible :school_ids, as: [:developer, :designer, :superintendent,
    :principal]
  attr_accessible :district_ids, as: [:developer, :designer, :superintendent]
  
  belongs_to :pdf
  has_many :students
  has_many :schools, through: :students
  
  validates_presence_of :type
  validates_presence_of :pdf, if: :is_print?
  validates_inclusion_of :type, in: Export.types
  validate :students_in_scope
  validate :pdf_in_scope, :image_presence, :color_presence, if: :is_print?
  
  # Create methods to see if the export is a certain type.
  types.each do |t|
    define_method "is_#{t}?" do
      type == t
    end
  end
  
  # Pre-fetch all files associated with this export in parallel.
  def fetch_files
    require 'open-uri'
    Thread.current[:export_files] = Hash[file_urls.pmap do |url|
      [url, open(url)]
    end]
  end
  
  # The urls of each file associated with this export.
  def file_urls
    urls = { pdf.file.url => true }
    pdf.fonts.map { |font| urls[font.file.url] = true }
    if columns.include? 'image'
      students.map { |student| urls[student.image.url] = true }
    end
    if columns.include? 'school_mascot_image'
      schools.map { |school| urls[school.mascot_image.url] = true }
    end
    urls.keys
  end
  
  # Return the format for the given export.
  def format
    { 'print' => :pdf, 'zpass' => :csv }[type]
  end
  
  def content_type
    { 'print' => 'application/pdf', 'zpass' => 'text/plain' }[type]
  end
  
  # Return all students associated with this print job.
  def students
    @students ||= Student.find(student_ids)
  end
  
  # Store student ids and initialize when nil.
  def student_ids
    @student_ids ||= []
  end
  
  # Student ids setter method and initialize when nil.
  # - Dumps @students cache.
  # - Keeps ids unique with the union operator (|).
  # - Converts all ids to integers and gets rid of 0.
  def student_ids= ids
    @student_ids ||= []
    @students = nil
    @student_ids |= Array(ids).map(&:to_i) - [0]
  end
  
  # Setter method for district ids. When called, adds all student ids from the
  # corresponding model.
  [District, School, Period, User].each do |model|
    define_method "#{model.name.underscore}_ids=" do |ids|
      send :student_ids=, model.find(Array(ids)).map(&:student_ids).reduce(:+)
    end
  end
  
  # Returns all columns in the pdf.
  def columns
    pdf ? pdf.fields.map(&:column) : []
  end
  
  private
  
  # Ensure the current user is authorized to use the pdf.
  def pdf_in_scope
    if pdf && !(School.with_permissions_to(:show).pluck(:id) | pdf.school_ids).any?
      errors.add :base, 'The template must be viewable by you'
    end
  end
  
  # Ensure the current user is authorized to print the current students.
  def students_in_scope
    common = student_ids & Student.with_permissions_to(:show).map(&:id)
    if common.length < student_ids.length
      errors.add :base, 'Exported students must be viewable by you'
    end
  end
  
  # If columns includes image or school mascot image, ensure each student has
  # an image and their school has a mascot image.
  def image_presence
    if (columns | Export.image_columns).present?
      image_present = columns.include?('image')
      mascot_present = columns.include?('school_mascot_image')
      
      students.each do |student|
        if image_present && !student.image?
          errors.add :base, 'Exported students must each have an image for this template'
          break
        elsif mascot_present && !student.school.mascot_image?
          errors.add :base, 'Exported students\' schools must have a mascot image for this template'
          break
        end
      end
    end
  end
  
  # If color columns are present in the template, ensure all students have a
  # bus route with a color value.
  def color_presence
    if (columns | Export.color_columns).present?
      bus_route_present = columns.include?('bus_route_color_value')
      
      students.each do |student|
        if bus_route_present && student.bus_route_color_value.blank?
          errors.add :base, 'Exported students must each have a bus route with a color'
          break
        end
      end
    end
  end
  
end