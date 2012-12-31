module Resources
  
  # When included, add a helper method.
  def self.included base
    base.helper_method :new_resource, :find_collection, :find_first_parent
  end

  private
  
  # Find the parent for the current controller, if there is a parent, return
  # the corresponding children, if not return the model for the current
  # controller.
  def find_collection model = controller_model
    parent = find_first_parent
    collection = parent ? parent.send(type_of(model)) : model
    collection = collection.with_permissions_to(:show)
    collection = collection.limit(offset_amount).offset(params[:offset].to_i)
    
    if params[:order].present? && valid_order_column?(model, params[:order])
        collection = collection.reorder(params[:order])
    end
    
    if params[:search].present? && collection.respond_to?(:search)
      collection = collection.search(params[:search])
    end
    
    collection
  end
  
  # Find the first available parent.
  def find_first_parent model = controller_model
    defined?(@first_parent) ? @first_parent : @first_parent = begin
      if parents = PARENTS[type_of(model)]
        parents.any? do |parent|
          id = params[:"#{parent.name.underscore}_id"]
          if id && parent.reflect_on_association(type_of(model))
            return parent.find(id)
          end
        end
      end
    end
  end
  
  # Creates a new resource for the given model and adds parent ids if they
  # are present in params.
  def new_resource model = controller_model
    resource || set_resource(model.new.tap do |record|
      settings = params[model.name.underscore] || {}
      attributes = params_with_parents(model).merge(settings)
      record.assign_attributes attributes, as: current_role
    end)
  end
  
  private
  
  def valid_order_column? model, order_statement
    order_statement_regex.match(order_statement) &&
      ($1 == model.table_name && model.column_names.include?($2)) ||
      ((reflection = model.reflect_on_association($1.to_sym)) &&
        valid_order_column?(reflection.klass, order_statement))
  end
  
  def order_statement_regex
    /\(?(\w+)\.(\w+)(( -> '\w+')(\)::int)?)? (asc|desc)/
  end
  
end