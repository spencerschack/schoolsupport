class TestScore < ActiveRecord::Base
  
  using_access_control
  
  attr_reader :dynamic_methods
  
  attr_accessible :student_id, :test_model_id, :term, as: [:developer,
    :superintendent, :principal, :teacher]
  
  belongs_to :student
  belongs_to :test_model
  has_many :test_values, autosave: true, inverse_of: :test_score
  
  validates_presence_of :student, :test_model
  validates_with Term
  validates_uniqueness_of :test_model_id, scope: [:term, :student_id]
  
  after_find :update_dynamic_methods
  after_initialize :set_term, on: :create
  
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
  
  private
  
  def set_term
    write_attribute(:term, Term.current) unless term.present?
  end
  
  # Ensure the proper instance variables are initialized, undefine all previous
  # methods and define the new ones.
  def update_dynamic_methods
    @dynamic_methods ||= []
    @test_value_cache ||= {}
    undefine_dynamic_methods if @dynamic_methods.any?
    define_dynamic_methods
  end
  
  # Create methods for the test attributes and cache the test values.
  def define_dynamic_methods
    if new_record?

      # If the record is new, load the test attributes and build new test
      # values.
      test_model.test_attributes.each do |test_attribute|
        method_name = test_attribute.name
        @dynamic_methods << method_name
        @test_value_cache[method_name] = test_values.build do |test_value|
          test_value.test_attribute_id = test_attribute.id
        end
      end
    else
      
      # If the record has been saved, just load the test values and include
      # the test attributes.
      test_values.includes(:test_attribute).each do |test_value|
        method_name = test_value.test_attribute.name
        @dynamic_methods << method_name
        @test_value_cache[method_name] = test_value
      end
    end
    
    # Define reader and writer methods for the test attributes.
    @dynamic_methods.each do |method_name|
      define_singleton_method method_name do
        @test_value_cache[method_name].value
      end
      define_singleton_method "#{method_name}=" do |value|
        @test_value_cache[method_name].value = value
      end
    end
    
    # Add the dynamic methods to the accessible attributes.
    singleton_class.attr_accessible *@dynamic_methods, as: [:developer,
      :superintendent, :principal, :teacher]
  end
  
  # Dump all test values and remove the dynamic mehods on this singleton class.
  def undefine_dynamic_methods
    test_values.destroy_all
    @dynamic_methods.each do |method_name|
      singleton_class.remove_method method_name, "#{method_name}="
    end
    @dynamic_methods.clear
    @test_value_cache.clear
  end
end
