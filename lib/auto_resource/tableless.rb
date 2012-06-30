# Defines a model that is not persisted in the database.
class Tableless < ActiveRecord::Base

  def self.table_name
      self.name.tableize
  end

  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  def self.columns_hash
    @columns_hash ||= Hash[columns.map { |column| [column.name, column] }]
  end

  def self.column_names
    @column_names ||= columns.map { |column| column.name }
  end

  def self.column_defaults
    @column_defaults ||= columns.map { |column| [column.name, nil] }.inject({}) { |m, e| m[e[0]] = e[1]; m }
  end

  def self.descends_from_active_record?
    return true
  end
  
  def to_key
    nil
  end

  def persisted?
    return false
  end

  def save( opts = {} )
    options = { :validate => true }.merge(opts)
    options[:validate] ? valid? : true
  end
end