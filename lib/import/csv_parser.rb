class CsvParser

  def self.read path, &block
    require 'csv'
    array = []
    CSV.foreach(path, { headers: true }) { |row| array << row.to_hash }
    array.peach(&block)
  end
  
end