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
    expire_action(controller: record.class.model_name.underscore.pluralize, action: 'index')
  end
  
end