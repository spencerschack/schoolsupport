class ImportJob
  
  @queue = :import
  
  attr_accessor :import_data
  
  delegate :model, :defaults, :prompt_values, :update_ids, :user, to: :import_data
  
  def self.perform id
    ImportJob.new(id)
  end
  
  def initialize id
    @import_data = ImportData.find(id)
    Authorization.current_user = user
    import_data.model.transaction do
      create_records
      drop_records
    end
    import_data.destroy
  rescue => error
    Rails.logger.info "[import file error] #{error.message}"
    Rails.logger.info error.backtrace.join("\n")
    raise error
  ensure
    cleanup
  end
  
  def cleanup
    Authorization.current_user = nil
    
    prev = Authorization.ignore_access_control
    Authorization.ignore_access_control(true)
    
    ImportData.where('created_at < ?', 1.day.ago).destroy_all
    Resque.redis.ltrim(:failed, -1, -100)
    
    Authorization.ignore_access_control(prev)
  end
  
  def parser
    options[:parser] || CsvParser
  end
  
  def options
    model.has_import_options
  end
  
  def file
    @file ||= begin
      require 'open-uri'
      open(import_data.file.url)
    end
  end
  
  private
  
  def create_records
    current_role = user.role_symbols.first
    parser.read(file) do |hash, index|
      begin
        Authorization.current_user = user
        process(hash = hash.with_indifferent_access)
        record = new_record(hash)
        record.assign_attributes(hash, as: current_role)
        record.save!
        dropped_ids.delete(record.id)
      rescue => error
        raise error.exception("Row #{index}: #{error.message}")
      ensure
        ActiveRecord::Base.connection.close
      end
    end
  end
  
  def drop_records
    if dropped_ids.any? && model.respond_to?(:drop_ids)
      model.drop_ids(dropped_ids, as: user.role_symbols.first)
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
  
  def without_access_control
    previous_state = Authorization.ignore_access_control
    Authorization.ignore_access_control(true)
    result = yield
  ensure
    Authorization.ignore_access_control(previous_state)
    result
  end

end