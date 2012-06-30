# Methods for automatically finding resource parents.
module Parents
  
  # When included, add the methods as helper methods.
  def self.included base
    base.helper_method :parent_path, :resource_with_parents
  end
  
  private
  
  # Add associations to a new record.
  def params_with_parents model, attributes = {}
    if parents = PARENTS[type_of(model)]
      parents.each do |parent|
        if id = params[id_attr(parent)]

          if model.reflect_on_association id_attr(parent)
            attributes[id_attr(parent)] = id
          elsif model.reflect_on_association ids_attr(parent)
            attributes[ids_attr(parent)] = id
          end
        end
      end
    end
    attributes
  end
  
  # Finds the correct path for the given index or show.
  def corrected_path
    unless controller_model
      request.path
    else
      if action_name == 'index'
        parent_path(controller_model)
      elsif action_name == 'show'
        parent_path(controller_model.find(params[:id]))
      elsif action_name == 'new'
        parent_path(new_resource)
      end
    end
  end
  
  # Add parents to record and call polymorphic_path for those records.
  def parent_path record, options = {}
    first = Array.wrap(record).first
    if first.respond_to?(:new_record?) && first.new_record?
      options.merge!(action: :new)
    end
    polymorphic_path(resource_with_parents(record), options)
  end
  
  # Prepend parents of the given record to the array or record given and
  # return the array. Parents are determined by params and PARENTS.
  def resource_with_parents record
    if parents = PARENTS[type_of(record)]
      array = Array(record)
      first = array.first
      
      parents.each do |model|
        if id = params[id_key(model)]
          
          if first.is_a?(Symbol) || first.is_a?(Class)
            array.unshift model.find(id)
          else
            
            if first.respond_to?(ids_attr(model))
              if first.send(ids_attr(model)).include?(id.to_i)
                array.unshift model.find(id)
              end
            else
              array.unshift first.send(model.name.underscore)
            end
          end

        end
      end
      array
    else
      record
    end
  end
  
  private
  
  # Return the symbol representing the key for the model in params.
  def id_key model
    model == controller_model ? :id : :"#{model.name.underscore}_id"
  end
  
  # Return the underscored, pluralized symbol representing the class of the
  # record.
  def type_of record
    return record if record.is_a? Symbol
    record = record.class unless record.is_a?(Class)
    record.model_name.pluralize.underscore.to_sym
  end
  
  # Returns the id attribute for the given model and optionally an appended
  # equals sign.
  def id_attr model
    :"#{model.name.underscore}_id"
  end
  
  # Pluralizes id_attr.
  def ids_attr model
    :"#{id_attr(model)}s"
  end
end