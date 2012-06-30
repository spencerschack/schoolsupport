module Resources
  
  # When included, add a helper method.
  def self.included base
    base.helper_method :new_resource
  end

  private
  
  # Find the parent for the current controller, if there is a parent, return
  # the corresponding children, if not return the model for the current
  # controller.
  def find_collection model = controller_model
    if parents = PARENTS[type_of(model)]
      parents.each do |parent|
        id = params[:"#{parent.name.underscore}_id"]
        if id && parent.reflect_on_association(type_of(model))
          collection = parent.find(id).send(type_of(model))
          return collection.with_permissions_to(:show)
        end
      end
    end
    model.with_permissions_to(:show)
  end
  
  # Creates a new resource for the given model and adds parent ids if they
  # are present in params.
  def new_resource model = controller_model
    resource || set_resource(model.new.tap do |record|
      if param = params[model.name.underscore]
        attributes = params_with_parents(model, param)
      else
        attributes = {}
      end
      record.assign_attributes attributes, as: current_role
    end)
  end
  
end