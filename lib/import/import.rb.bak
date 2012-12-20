class Import
  
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :model, :file, :defaults, :update_ids, :prompt_values
  
  validate :model_import
  validate :file_type
  
  def self.for? model_or_record
    model_or_record = model_or_record.class unless model_or_record.is_a? Class
    model_or_record.has_import_options.present?
  end
  
  def initialize options = nil
    if options
      options[:update_ids] ||= []
      if options[:prompt_values].is_a?(Hash)
        options[:prompt_values].reject! { |key, value| value.blank? }
      end
      [:model, :file, :defaults, :update_ids, :prompt_values].each do |option|
        send("#{option}=", options[option])
      end
    end
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
    Rails.logger.info "[import file error] #{error.message}"
    Rails.logger.info error.backtrace.join("\n")
  end
  
  class Row
    include ActiveModel::Validations
    extend ActiveModel::Naming
  end
  
  def row
    @row_instance ||= Row.new.tap { |row| row.valid? }
  end
  
  def parser
    options[:parser] || CsvParser
  end
  
  def prompts
    if options[:prompts].respond_to?(:call)
      options[:prompts].call()
    else
      options[:prompts]
    end || []
  end
  
  def options
    model.has_import_options
  end
  
  def persisted?
    false
  end
  
  private
  
  def create_records path
    current_user = Authorization.current_user
    current_role = current_user.role_symbols.first
    parser.read(path) do |hash, index|
      begin
        Authorization.current_user = current_user
        process(hash = hash.with_indifferent_access)
        record = new_record(hash)
        record.assign_attributes(hash, as: current_role)
        record.save!
        dropped_ids.delete(record.id)
      rescue => error
        row.errors.add :"row_#{index}", error.message
      ensure
        ActiveRecord::Base.connection.close
      end
    end
  end
  
  def drop_records
    if dropped_ids.any? && model.respond_to?(:drop_ids)
      model.drop_ids(dropped_ids, as:
        Authorization.current_user.role_symbols.first)
    end
  end
  
  def dropped_ids
    @dropped_ids ||= Set.new.tap do |set|
      update_ids.each { |id| set.add(id.to_i) }
    end
  end
  
  def process hash
    hash.reverse_merge!(defaults) if defaults
    hash.reverse_merge!(prompt_values) if prompt_values
    options[:associate].each do |record, field|
      if value = hash.delete(record)
        finder = record.to_s.camelize.constantize
        attempted = finder.send("find_by_#{field}!", value)
        hash[:"#{record}_id"] = attempted.id
      end
    end if options[:associate].present?
  end
  
  def new_record hash
    options[:identify_with].each do |identifier, scopes|
      if hash[identifier]
        finder = model
        Array.wrap(scopes).compact.each do |scope|
          if !hash[scope]
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