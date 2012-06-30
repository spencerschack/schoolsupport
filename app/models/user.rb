class User < ActiveRecord::Base

  using_access_control

  attr_accessible :email, :password, :password_confirmation, :first_name,
    :last_name, :name, as: [:developer, :superintendent, :principal, :teacher]
  attr_accessible :school_id, as: [:developer, :superintendent]
  attr_accessible :period_ids, as: [:developer, :superintendent, :principal]
  attr_accessible :role_id, as: :developer

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end

  belongs_to :school
  has_one :district, through: :school
  belongs_to :role
  has_and_belongs_to_many :periods
  has_many :students, through: :periods
  
  has_import format: :csv, identify_with: { email: nil, name: :school_id },
    associate: { school: :name, role: :name }

  validates_presence_of :email, :school, :first_name, :last_name
  validates_confirmation_of :password, if: :password_changed?
  validates_uniqueness_of :first_name, scope: [:last_name, :school_id],
    message: 'is the same as another user with the same last name in the same school, add a middle initial'
  validate :presence_of_role
  validate :presence_of_school
  validate :periods_in_school
  validate :school_in_district
  
  def self.find_by_name name
    first, last = extract_name_parts(name)
    where(first_name: first, last_name: last).first
  end
  
  def self.find_by_name! name
    record = find_by_name(name)
    unless record
      raise RecordNotFound, "Couldn't find User with name = #{name}"
    end
    record
  end
  
  def self.find_or_initialize_by_name name
    find_by_name(name) || new(name: name)
  end
  
  def name reversed = true
    reversed ? "#{last_name}, #{first_name}" : "#{first_name} #{last_name}"
  end
  
  def name= value
    first_name, last_name = extract_name_parts(name)
  end

  # Returns an array of the symbol of the role of the user.
  def role_symbols
  	[role_symbol]
  end
  
  # Return underscored symbol form of role name or nil.
  def role_symbol
    role.name.underscore.to_sym
  end
  
  private
  
  # Return the first and last name from the given string.
  def extract_name_parts name
    if name =~ /,/
      parts = name.split(',')
      [parts.last, parts.first].map(&:strip)
    else
      parts = name.split
      [parts[0..-2].join(' '), parts.last].map(&:strip)
    end
  end
  
  # For principals that cannot edit school_id, add school for them.
  def presence_of_school
    # school_id = Authorization.current_user.school_id unless school_id
  end
  
  # If no role was set, add teacher.
  def presence_of_role
    role = Role.find_by_name('Teacher') unless role
  end
  
  # If the periods are not in the specified school, then add an error.
  def periods_in_school
    if periods.map(&:school_id).any?{|id| id != school_id }
      errors.add(:periods, 'must be in the school specified')
    end
  end
  
  # If the given school is not in the current user's scope of districts, then
  # add an error.
  def school_in_district
    unless permitted_to? :show, object: school.district
      errors.add(:school, 'must be in your district')
    end
  end

end
