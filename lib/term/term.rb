class Term < ActiveModel::Validator
  
  # Validate presence and format of a record's term.
  def validate record
    if record.term.blank?
      record.errors.add :term, 'can\'t be blank'
    elsif !Term.valid?(record.term)
      record.errors.add :term, 'must be in the format: YYYY-YYYY'
    end
  end
  
  # Returns whether the given term is a valid representation of a term.
  def self.valid? term
    !!(term =~ /(\d{4})-(\d{4})/ && $1.to_i + 1 == $2.to_i)
  end
  
  # Return the first year of the current term.
  def self.current_year
    (now = Time.now).month > 6 ? now.year : now.year - 1
  end
  
  # Return the string representation of the current term.
  def self.current
    Term.for Term.current_year
  end
  
  # Return the string representation of the previous term.
  def self.previous
    Term.for(Term.current_year - 1)
  end
  
  # Return an array of choices for term values.
  def self.choices
    year = Time.now.year
    ((year - 50)..(year + 10)).map { |year| Term.for(year) }
  end
  
  # Return the string representation of the term for the given year.
  def self.for year
    "#{year}-#{year + 1}"
  end
  
end