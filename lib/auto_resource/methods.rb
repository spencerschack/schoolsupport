# Stores the default actions for a controller.
module Methods
  
  # Index action. Finds the collection and sets the collection variable.
  def index
    set_collection find_collection
    respond_with collection
  end
  
  # Import action.
  def import
    if params[:import]
      @import = Import.new(params[:import].merge({
        model: controller_model,
        role: current_role,
        defaults: params_with_parents(controller_model)
      }))
      @import.save
      respond_with @import
    else
      @import = Import.new
    end
  end
  
  # Export action.
  def export
    
  end

  # Show action.
  def show
    respond_with resource
  end

  # Edit action.
  def edit
    respond_with resource
  end
  
  # New Action.
  def new
    respond_with new_resource
  end

  # Create action. Save the resource created by declarative_authorization and
  # call respond_with.
  def create
    if resource.save
      # Set for resource_with_parents.
      params[:id] = resource.id
    end
    respond_with resource
  end

  # Update action. Update the record attributes with params as the current
  # user.
  def update
    resource.update_attributes params[params_key], as: current_role
    respond_with resource
  end

  # Destroy action. Call destroy on the record and call respond_with.
  def destroy
    resource.destroy
    respond_with resource
  end

  private
  
  # Return the key that represents where the attributes for the current
  # resource are stored in params.
  #   controller_name # => 'users'
  #   params_key # => :user
  def params_key
    controller_name.singularize.to_sym
  end
  
end