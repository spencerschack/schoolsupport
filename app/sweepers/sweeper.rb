class Sweeper < ActionController::Caching::Sweeper
  
  observe BusRoute, BusStop, District, Field, Font, Pdf, Period, Role,
    School, Student, Template, TestAttribute, TestGroup, TestModel, TestScore,
    TestValue, Type, User
  
  def after_create record
    expire_cache_for(record)
  end
  
  def after_update record
    expire_cache_for(record)
  end
  
  def after_destroy record
    expire_cache_for(record)
  end
  
  private
  
  def expire_cache_for record
    expired_models = [record.class]
    expired_models += case record
    when District
      [School, BusRoute, BusStop]
    when Pdf
      [Type]
    when Role
      [User]
    when School
      [Period]
    when Template
      [Pdf, Type]
    when TestGroup
      [TestModel]
    end || []
    
    expired_models.each do |model|
      expire_action(controller: controller_for(model), action: 'index')
    end
  end
  
  def controller_for record
    record.model_name.underscore.pluralize
  end
  
end