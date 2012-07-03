class Import
  
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :model, :file, :defaults, :role
  
  validate :model_import
  validate :file_type
  
  def self.for? model_or_record
    unless model_or_record.is_a? Class
      model_or_record = model_or_record.class
    end
    model_or_record.has_import_options.present?
  end
  
  def initialize options = nil
    [:model, :file, :defaults, :role].each do |option|
      send("#{option}=", options[option])
    end if options
  end
  
  def row
    @row_instance ||= Row.new.tap { |row| row.valid? }
  end
  
  def save
    if valid?
      model.transaction do
        create_records(file.path)
        if row.errors.any?
          errors.add :base, 'Import failure. No records were saved.'
          raise ActiveRecord::Rollback
        end
      end
    end
  rescue
    errors.add :base, 'File could not be read.'
  end
  
  def create_records path
    index = 1
    parser.read(path) do |hash|
      begin
        process(hash = hash.with_indifferent_access)
        record = new_record(hash)
        record.assign_attributes hash, as: role
        record.save!
      rescue StandardError => error
        row.errors.add :"row_#{index}", error.message
      ensure
        index += 1
      end
    end
  end
  
  def process hash
    hash.reverse_merge!(defaults) if defaults
    options[:associate].each do |record, (field, method)|
      if value = hash.delete(record)
        finder = record.to_s.camelize.constantize
        attempted = finder.send("find_by_#{field}!", value)
        if method.is_a?(Symbol) && model.respond_to?(method)
          model.send(method, hash, attempted, role)
        else
          hash[:"#{record}_id"] = attempted.id
        end
      end
    end if options[:associate].present?
  end
  
  def parser
    options[:parser] || CsvParser
  end
  
  def options
    model.has_import_options
  end
  
  def persisted?
    false
  end
  
  private
  
  def new_record hash
    options[:identify_with].each do |identifier, scope|
      if hash[identifier]
        finder = model
        if scope
          unless hash[scope]
            raise ArgumentError, "To find a #{model.name.titleize.downcase} by" <<
              " #{identifier}, you must also enter a #{scope.to_s.humanize.downcase}"
          else
            finder = finder.where(scope.to_sym => hash[scope])
          end
        end
        record = finder.send("find_by_#{identifier}", hash[identifier])
        return record if record
      end
    end
    model.new
  end
  
  def model_import
    unless Import.for? model
      errors.add :base, 'The selected model does not have import capabilities.'
    end
  end
  
  def file_type
    unless file.respond_to? :path
      errors.add :file, 'is not a valid file'
    end
  end

end
  
class Row
  include ActiveModel::Validations
  extend ActiveModel::Naming
end