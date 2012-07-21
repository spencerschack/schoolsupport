class Test < ActiveRecord::Base
  
  using_access_control
  
  attr_accessible :term, :student_id,
    as: [:teacher, :principal, :superintendent, :developer]
  
  belongs_to :student
  has_many :users, through: :student
  has_many :periods, through: :student
  has_one :school, through: :student
  has_one :district, through: :student
  
  serialize :data, OpenStruct
  
  has_import identify_with: { student_id: [:type, :term] }, associate: { student: :identifier }
  
  validates_uniqueness_of :student_id, scope: [:type, :term]
  
  # When called in subclasses, it delegates the given methods to the data
  # column, which is an OpenStruct object so it responds to all method calls.
  def self.data_columns *columns
    columns += columns.map { |col| :"#{col}=" }
    delegate *columns, to: :data
  end
  
end
