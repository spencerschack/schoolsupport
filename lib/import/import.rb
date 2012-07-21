class Import
  
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :model, :file, :defaults, :update_ids
  
  validate :model_import
  validate :file_type
  
  def self.for? model_or_record
    unless model_or_record.is_a? Class
      model_or_record = model_or_record.class
    end
    model_or_record.has_import_options.present?
  end
  
  def initialize options = nil
    if options
      options[:update_ids] ||= []
      [:model, :file, :defaults, :update_ids].each do |option|
        send("#{option}=", options[option])
      end
    end
  end
  
  def dropped_ids
    @dropped_ids ||= Set.new.tap do |set|
      update_ids.each { |id| set.add(id.to_i) }
    end
  end
  
  class Row
    include ActiveModel::Validations
    extend ActiveModel::Naming
  end
  
  def row
    @row_instance ||= Row.new.tap { |row| row.valid? }
  end
  
  def save
    if valid?
      model.transaction do
        create_records(file.path)
        drop_records
        if row.errors.any?
          errors.add :base, 'Import failure. No records were affected.'
          raise ActiveRecord::Rollback
        end
      end
    end
  rescue => error
    errors.add :base, "File error: #{error.message}"
  end
  
  def create_records path
    index = 1
    current_user = Authorization.current_user
    parser.read(path) do |hash|
      begin
        Thread.current[:current_user] = current_user
        process(hash = hash.with_indifferent_access)
        record = new_record(hash)
        record.assign_attributes(hash, as: current_user.role_symbols.first)
        record.save!
        dropped_ids.delete(record.id)
      rescue => error
        row.errors.add :"row_#{index}", error.message
      ensure
        ActiveRecord::Base.connection.close
        index += 1
      end
    end
  end
  
  def drop_records
    if dropped_ids.any? && model.respond_to?(:drop_ids)
      model.drop_ids(dropped_ids, as:
        Authorization.current_user.role_symbols.first)
    end
  end
  
  def process hash
    hash.reverse_merge!(defaults) if defaults
    options[:associate].each do |record, field|
      if value = hash.delete(record)
        finder = record.to_s.camelize.constantize
        attempted = finder.send("find_by_#{field}!", value)
        hash[:"#{record}_id"] = attempted.id
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
    options[:identify_with].each do |identifier, *scopes|
      if hash[identifier]
        finder = model
        scopes.each do |scope|
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