class TestAttribute < ActiveRecord::Base
  
  using_access_control
  
  searches :name
  
  acts_as_tree
  
  attr_accessible :name, :parent_id, :test_model_id, :maximum_value, :advanced_proficient_boundary,
    :proficient_basic_boundary, :basic_below_basic_boundary,
    :below_basic_far_below_basic_boundary, :minimum_value, as: [:developer,
    :superintendent, :principal, :teacher]
  
  belongs_to :test_model
  
  validates_presence_of :name, :test_model
  validate :valid_parent
  
  def leveled?
    @leveled ||= maximum_value.present? && advanced_proficient_boundary.present? &&
      proficient_basic_boundary.present? && basic_below_basic_boundary.present? &&
      below_basic_far_below_basic_boundary.present? && minimum_value.present?
  end
  
  private
  
  def valid_parent
    if parent_id? && !test_model.test_attributes.where(parent_id: nil).pluck(:id).include?(parent_id)
      errors.add :parent_id, 'must be a root attribute of the same test model'
    end
  end
end
