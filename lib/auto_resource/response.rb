module Response
  
  # When included, have the controller respond to the following methods.
  # Necessary for respond_with to work.
  def self.included base
    base.respond_to :html
    base.prawn_options = { skip_page_creation: true }
  end
  
  private
  
  # If the action is update, create, or destroy, override default behavior to
  # respond with the appropriate json.
  def respond_with record
    case action_name
    when 'create', 'update', 'import', 'export'
      if record.errors.any?
        render json: failure_hash(record)
      elsif action_name == 'export'
        if request.xhr?
          render json: { success: true, format: record.format }
        else
          render "exports/#{record.type}",
            formats: [record.format],
            content_type: record.content_type,
            layout: false
        end
      else
        render json: success_hash(record)
      end
    when 'destroy'
      if record.errors.any?
        render json: destroy_failure_hash(record)
      else
        render json: destroy_success_hash(record)
      end
    else
      super
    end
  end
  
  # The object to return in case of a success.
  def success_hash record
    {}.tap do |hash|
      hash[:success] = true
      hash[:page] = render_to_string(view_for(true))
      if action_name == 'update' || action_name == 'create'
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
  
  # Success object for destroy.
  def destroy_success_hash record
    {
      success: true,
      id: record.id
    }
  end
  
  # Failure object for destroy.
  def destroy_failure_hash record
    {
      success: false,
      page: render_to_string('show')
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