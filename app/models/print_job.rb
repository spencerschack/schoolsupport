class PrintJob < Tableless
  
  column :template_id, :integer
  
  attr_accessible :student_ids, :template_id, :period_ids, :user_ids,
    as: [:developer, :designer, :superintendent, :principal, :teacher]
  attr_accessible :school_ids, as: [:developer, :designer, :superintendent,
    :principal]
  attr_accessible :district_ids, as: [:developer, :designer, :superintendent]
  
  belongs_to :template
  has_many :students
  
  validates_presence_of :template
  validate :template_in_scope
  validate :students_in_scope
  validate :students_have_images
  
  # Necessary for the default show.html.haml view.
  def name
    'Print Job'
  end
  
  # Return all students associated with this print job.
  def students
    @students ||= Student.find(student_ids)
  end
  
  def student_ids
    @student_ids ||= []
  end
  
  def student_ids= ids
    @student_ids ||= []
    @students = nil
    @student_ids |= (Array(ids).reject(&:blank?).map(&:to_i) - [0])
  end
  
  def district_ids= ids
    send :student_ids=, Array(District.find(ids)).map(&:student_ids).reduce(:+)
  end
  
  def school_ids= ids
    send :student_ids=, Array(School.find(ids)).map(&:student_ids).reduce(:+)
  end
  
  def period_ids= ids
    send :student_ids=, Array(Period.find(ids)).map(&:student_ids).reduce(:+)
  end
  
  def user_ids= ids
    send :student_ids=, Array(User.find(ids)).map(&:student_ids).reduce(:+)
  end
  
  private
  
  # Ensure the current user is authorized to use the template.
  def template_in_scope
    unless Template.with_permissions_to(:show).map(&:id).include?(template_id)
      errors.add :template, 'must be viewable by you'
    end
  end
  
  # Ensure the current user is authorized to print the current students.
  def students_in_scope
    common = student_ids & Student.with_permissions_to(:show).map(&:id)
    if common.length < student_ids.length
      errors.add :students, 'must be viewable by you'
    end
  end
  
  def students_have_images
    if template.fields.map(&:column).include?('image')
      students.each do |student|
        unless student.image?
          errors.add :students, 'must each have an image'
          break
        end
      end
    end
  end
  
end
