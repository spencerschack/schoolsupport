class ExportData < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :additional_information, :certificate_title, :student_ids,
    :distribution_date, :kind, :prompt_values, :sort_by, :type_id, :user_id,
    as: [:developer, :superintendent, :principal, :teacher]
  
  belongs_to :user
  belongs_to :type
  has_and_belongs_to_many :students
  has_many :schools, through: :students
  
  serialize :prompt_values, Hash
  
  has_attached_file :file, path: '/export_files/:id/:filename'
  
  validates_presence_of :kind
  validates_presence_of :certificate_title, :distribution_date, if: :is_request?
  validates_presence_of :type, if: :is_print?
  validates_inclusion_of :sort_by, in: Student.sorts, allow_blank: true
  validate :students_in_scope, :students_count
  validate :type_in_scope, :image_presence, :color_presence, if: :is_print?
  
  def template
    pdf.try(:template)
  end
  
  def pdf
    type.try(:pdf)
  end
  
  def file_path
    "export_files/#{id}.#{format}"
  end
  
  # Create methods to see if the export is a certain kind.
  ExportJob.kinds.each do |t|
    define_method "is_#{t}?" do
      kind == t
    end
  end
  
  def students
    if sort_by == 'teacher'
      super.includes(:users).order('users.last_name')
    else
      super.order(sort_by)
    end
  end
  
  # Return the format for the given export.
  def format
    { 'print' => :pdf, 'zpass' => :csv }[kind]
  end
  
  # Return the content type for the given export.
  def content_type
    { 'print' => 'application/pdf', 'zpass' => 'text/plain' }[kind]
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
  
  def students_count
    unless student_ids.count > 0
      errors.add :base, 'You must export at least one student.'
    end
  end
  
  # If columns includes image or school mascot image, ensure each student has
  # an image and their school has a mascot image.
  def image_presence
    if (columns | ExportJob.necessary_image_columns).present?
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
    if (columns | ExportJob.color_columns).present?
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
