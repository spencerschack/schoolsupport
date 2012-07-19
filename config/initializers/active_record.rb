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
  
end