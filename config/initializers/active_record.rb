module ActiveRecord
  
  class Base
    
    # Specify a default, look below at cache_key for details.
    def self.cache_key_timestamp_column
      :updated_at
    end
  
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
  
  class Relation
    
    # Returns a cache key for the given relation. Calculated by retreiving the
    # most recent updated at timestamp.
    def cache_key
      column_name = "#{table_name}.#{cache_key_timestamp_column}"
      latest_time = order(column_name).limit(1).pluck(:updated_at).first
      "#{model_name.cache_key}-#{latest_time.try(:to_s, :number)}"
    end
    
  end
  
end