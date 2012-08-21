class TestScore < ActiveRecord::Base
  
  @@skip_dynamic_methods = false
  
  using_access_control
  
  attr_writer :dynamic_methods
  
  attr_accessible :student_id, :test_model_id, :term, as: [:developer,
    :superintendent, :principal, :teacher]
  
  belongs_to :student
  has_many :periods, through: :student
  has_many :users, through: :periods
  has_one :school, through: :student
  has_one :district, through: :school
  belongs_to :test_model
  has_many :test_attributes, through: :test_model
  has_many :test_values, inverse_of: :test_score, dependent: :destroy, include: :test_attribute
  
  has_import identify_with: { test_model_id: [:term, :student_id] },
    associate: { student: :identifier, test_model: :name },
    prompts: proc { [[:test_model, collection: TestModel.with_permissions_to(:show).map(&:name)],
      [:term, collection: Term.choices]] }
  
  validates_presence_of :student, :test_model
  validates_with Term
  validates_uniqueness_of :test_model_id, scope: [:term, :student_id]
  validate :test_model_in_district
  
  after_find :update_dynamic_methods
  after_initialize :set_term, on: :create
  after_save :save_updated_test_values
  
  def self.without_dynamic_methods
    @@skip_dynamic_methods = true
    yield if block_given?
  ensure
    @@skip_dynamic_methods = false
  end
  
  def dynamic_methods
    @dynamic_methods || define_dynamic_methods
  end
  
  def name
    test_model.try(:name) || 'Test Score'
  end
  
  # Override to ensure test_model_id is set before anything else.
  def assign_attributes attributes, options = {}
    attributes.stringify_keys!
    super(attributes.extract!('test_model_id'), options) if attributes.has_key?('test_model_id')
    super(attributes, options)
  end
  
  # Override to call update_dynamic_methods if the test_model_id changed.
  def test_model_id= value
    super
    update_dynamic_methods if test_model_id_changed?
  end
  
  # Ensure the proper instance variables are initialized, undefine all previous
  # methods and define the new ones.
  def update_dynamic_methods
    return if @@skip_dynamic_methods
    undefine_dynamic_methods
    define_dynamic_methods
  end
  
  private
  
  # Set term as current term if not already set.
  def set_term
    write_attribute(:term, Term.current) unless term.present?
  end
  
  # Manually save updated test values because autosave: true on the association
  # does not recognize changes on the test value objects referenced in the
  # dynamic methods.
  def save_updated_test_values
    @updated_test_values.each(&:save)
  end
  
  # Create methods for the test attributes and cache the test values.
  def define_dynamic_methods
    return unless test_model_id?
    @dynamic_methods ||= []
    @updated_test_values ||= Set.new
    if new_record?
      test_model.test_attributes.each do |test_attribute|
        define_dynamic_method(test_attribute.name, test_values.build do |test_value|
          test_value.test_attribute_id = test_attribute.id
        end)
      end
    else
      test_values.each do |test_value|
        define_dynamic_method test_value.test_attribute.name, test_value
      end
    end
    self.class.attr_accessible *@dynamic_methods, as: [:developer, :superintendent, :principal, :teacher]
    @dynamic_methods
  end
  
  # Create setter and getter methods.
  def define_dynamic_method name, object
    @dynamic_methods << name.to_sym
    define_singleton_method name do
      object.value
    end
    define_singleton_method "#{name}=" do |value|
      object.value = value
      @updated_test_values << object if object.value_changed?
      value
    end
  end
  
  # Dump all test values and remove the dynamic mehods on this singleton class.
  def undefine_dynamic_methods
    return unless @dynamic_methods.try(:any?)
    test_values.destroy_all
    @dynamic_methods.each do |method_name|
      singleton_class.send :remove_method, method_name, "#{method_name}="
    end
    @dynamic_methods.clear
    @updated_test_values.clear
  end
  
  def test_model_in_district
    unless test_model.test_group.district_ids.include? student.district.id
      errors.add :test_model, 'cannot be used for this student'
    end
  end
end
