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
    @find_collection ||= if first_parent = find_first_parent(model)
      collection = first_parent.send(type_of(model))
    else
      model
    end.with_permissions_to(:show)
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
  
end