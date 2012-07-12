module CsvParser

  def self.read path, &block
    require 'csv'
    options = { headers: true, header_converters: :symbol }
    array = []
    CSV.foreach(path, options) { |row| array << row.to_hash }
    array.peach(&block)
  end
  
end