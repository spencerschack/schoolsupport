class TestScore < ActiveRecord::Base
  
  def self.levels
    %w(adv prof basic bbasic fbb)
  end
  
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
      [:school, collection: School.with_permissions_to(:show).order('name').map do |school|
        [school.to_label, school.identifier]
      end ]] },
    processor: TestScoreProcessor
  
end
