class TestValue < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :test_attribute_id, :test_score_id, :value, as: [:developer,
    :superintendent, :principal, :teacher]
  
  belongs_to :test_score
  belongs_to :test_attribute
  
  delegate :leveled?, :name, :maximum_value, :advanced_proficient_boundary,
    :proficient_basic_boundary, :basic_below_basic_boundary,
    :below_basic_far_below_basic_boundary, :minimum_value, to: :test_attribute
  
  validates_presence_of :test_attribute, :test_score
  validates_uniqueness_of :test_attribute_id, scope: [:test_score_id]
  
  # Returns string representation of the level of the test value. If the test
  # attribute is not leveled, return nil. Ranges are non-inclusive of the last
  # value (...), except for the last.
  def level
    @level ||= if leveled?
      case value
      when minimum_value...below_basic_far_below_basic_boundary
        'far_below_basic'
      when below_basic_far_below_basic_boundary...basic_below_basic_boundary
        'below_basic'
      when basic_below_basic_boundary...proficient_basic_boundary
        'basic'
      when proficient_basic_boundary...advanced_proficient_boundary
        'proficient'
      when advanced_proficient_boundary..maximum_value
        'advanced'
      else
        value > maximum_value ? 'maximum' : 'minimum'
      end
    else
      'unleveled'
    end
  end
end
