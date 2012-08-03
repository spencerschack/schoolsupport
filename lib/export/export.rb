class Export < Tableless
  
  # Return whether the given model or record is capable of having an export.
  def self.for? model_or_record
    return true if model_or_record.is_a?(Type)
    model_or_record = model_or_record.class unless model_or_record.is_a?(Class)
    model_or_record == Student || !!model_or_record.reflect_on_association(:students)
  end
  
  # What kind are accepted.
  def self.kinds
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
  
  column :type_id, :integer
  
  attr_accessor :kind, :prompt_values, :sort_by
  
  attr_accessible :students, :student_ids, :type_id, :period_ids,
    :user_ids, :kind, :prompt_values, :sort_by, as: [:developer,
    :superintendent, :principal, :teacher]
  attr_accessible :school_ids, as: [:developer, :superintendent,
    :principal]
  attr_accessible :district_ids, as: [:developer, :superintendent]
  
  belongs_to :type
  has_one :pdf, through: :type
  has_one :template, through: :pdf
  has_many :students
  has_many :schools, through: :students
  
  validates_presence_of :kind
  validates_presence_of :type, if: :is_print?
  validates_inclusion_of :sort_by, in: Student.sorts, allow_blank: true
  validate :students_in_scope
  validate :type_in_scope, :image_presence, :color_presence, if: :is_print?
  
  # Create methods to see if the export is a certain kind.
  kinds.each do |t|
    define_method "is_#{t}?" do
      kind == t
    end
  end
  
  # Pre-fetch all files associated with this export in parallel. A block is
  # provided to the hash so key lookup only depends on the path of the url.
  def fetch_files
    require 'open-uri'
    Thread.current[:export_files] = Hash.new do |hash, key|
      hash[key] = hash.has_key?(path = URI(key).path) ? hash[path] : nil
    end
    file_urls.each_with_object(Thread.current[:export_files]).pmap do |url, hash|
      hash[URI(url).path] = open(url)
    end
  end
  
  # After the export is done with all the files, empty the thread variable.
  def dump_files
    Thread.current[:export_files] = nil
  end
  
  # The urls of each file associated with this export.
  def file_urls
    urls = { pdf.file.url => true }
    template.fonts.map { |font| urls[font.file.url] = true }
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
    { 'print' => :pdf, 'zpass' => :csv }[kind]
  end
  
  # Return the content type for the given export.
  def content_type
    { 'print' => 'application/pdf', 'zpass' => 'text/plain' }[kind]
  end
  
  # Return all students associated with this print job.
  def students
    @students ||= Student.order(sort_by).find(student_ids)
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
  
  # Returns all columns in the template.
  def columns
    template ? template.fields.map(&:column) : []
  end
  
  private
  
  # Ensure the current user is authorized to use the pdf.
  def type_in_scope
    if type && !(School.with_permissions_to(:show).pluck(:id) | type.school_ids).any?
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