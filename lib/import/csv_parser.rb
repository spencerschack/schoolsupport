class CsvParser

  def self.read path, &block
    require 'csv'
    array = []
    index = 0
    CSV.foreach(path, { headers: true }) do |row|
      array << [row.to_hash, index += 1]
    end
    array.peach(&block)
  end
  
end