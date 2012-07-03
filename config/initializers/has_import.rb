module HasImport
  
  def self.extended base
    base.class_attribute :has_import_options
  end
  
  def has_import options
    self.has_import_options = options
  end
  
end

ActiveRecord::Base.extend HasImport