module Response
  
  # When included, have the controller respond to the following methods.
  # Necessary for respond_with to work.
  def self.included base
    base.respond_to :html, :json
  end
  
  private
  
  # If the action is update, create, or destroy, override default behavior to
  # respond with the appropriate json.
  def respond_with record
    case action_name
    when 'create', 'update', 'import'
      if record.errors.any?
        render json: failure_hash(record)
      else
        render json: success_hash(record)
      end
    when 'destroy'
      render nothing: true
    else
      super
    end
  end
  
  # The object to return in case of a success.
  def success_hash record
    {}.tap do |hash|
      hash[:page] = render_to_string(view_for(true))
      hash[:success] = true
      unless action_name == 'import'
        hash[:row] = render_to_string('_row', layout: false)
        hash[:path] = parent_path(record)
      end
    end
  end
  
  # The object to return in case of a failure.
  def failure_hash record
    {
      page: render_to_string(view_for(false)),
      success: false,
      errors: record.errors
    }
  end
  
  # Which view to render for the given action.
  def view_for success
    case action_name
    when 'update'
      success ? 'show' : 'edit'
    when 'create'
      success ? 'show' : 'new'
    when 'import'
      success ? 'index' : 'import'
    end
  end
  
end