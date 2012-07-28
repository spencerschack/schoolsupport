class ActiveRecord::Base
  
  # Creates a singleton function called search that uses LIKE to search
  # through the given columns.
  def self.searches *columns
    define_singleton_method :search do |query|
      statement = columns.map do |column|
        "LOWER(\"#{table_name}\".\"#{column}\") LIKE LOWER(?)"
      end.join(' OR ')
      where(statement, *["%#{query}%"] * columns.length)
    end
  end
  
  # Relations that can be termed extend this.
  module WithTermExtension
    def with_term term = Term.current
      if proxy_association.reflection.klass == Period
        where(term: term)
      else
        joins(:periods).where(periods: { term: term })
      end
    end
  end
  
end