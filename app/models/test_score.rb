# Possible levels in the data hstore include:
# - Adv
# - Prof
# - Basic
# - BBasic
# - FBB
class TestScore < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :data, :student_id, :term, :test_name,
    as: [:developer, :superintendent, :principal, :teacher]
  
  belongs_to :student
  
  serialize :data, ActiveRecord::Coders::Hstore
  
  validates_presence_of :student, :term, :test_name
  validates_with Term
  
  searches student: [:first_name, :last_name, :identifier]
  
  has_import identify_with: { student_id: [:term, :test_name] },
    prompts: proc { [[:term, collection: Term.options_for_select, include_blank: false],
      [:school, collection: School.with_permissions_to(:show)]] },
    processor: TestScoreProcessor
  
  def name
    "#{test_name} #{term}"
  end
  
end
