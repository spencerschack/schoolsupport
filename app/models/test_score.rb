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
  
  after_create :expire_data_columns_cache
  after_update :expire_data_columns_cache
  after_destroy :expire_data_columns_cache
  
  searches student: [:first_name, :last_name, :identifier]
  
  has_import identify_with: { student_id: [:term, :test_name] },
    prompts: proc { [[:term, collection: Term.options_for_select, include_blank: false],
      [:school, collection: School.with_permissions_to(:show)]] },
    processor: TestScoreProcessor
  
  def self.data_columns options = {}
    Rails.cache.fetch(data_columns_cache_key, options) do
      
      test_scores = TestScore.connection.execute(
        TestScore.uniq.select('test_scores.test_name, test_scores.term, skeys(test_scores.data)').to_sql)
      data_columns = {}
      test_scores.each do |test_score|
        
        test_name = test_score['test_name'].downcase
        term = test_score['term'].downcase
        data_columns[test_name] ||= {}
        data_columns[test_name][term] ||= Set.new
        data_columns[test_name][term] << test_score['skeys'].downcase
        
      end
      data_columns
    end
  end
  
  private
  
  def expire_data_columns_cache
    Rails.cache.delete(self.class.data_columns_cache_key)
  end
  
  def self.data_columns_cache_key
    'test_scores/data_columns'
  end
  
end
