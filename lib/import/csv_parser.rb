module CsvParser

  def self.read path, &block
    require 'csv'
    options = { headers: true, header_converters: :symbol }
    CSV.foreach(path, options) do |row|
      block.call(row.to_hash)
    end
  end
  
end