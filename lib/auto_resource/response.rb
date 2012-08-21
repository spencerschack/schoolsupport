module Response
  
  # When included, have the controller respond to the following methods.
  # Necessary for respond_with to work.
  def self.included base
    base.respond_to :html, :json
    base.prawn_options = { skip_page_creation: true }
  end
  
  private
  
  # If the action is update, create, or destroy, override default behavior to
  # respond with the appropriate json.
  def respond_with record
    case action_name
    when 'create', 'update', 'import'
      if record.errors.any?
        render json: failure_hash, content_type: 'text/plain'
      else
        render json: success_hash(record), content_type: 'text/plain'
      end
    when 'export'
      if record.errors.any?
        render text: record.errors.full_messages.join("\n")
      else
        render "exports/#{record.kind}",
          formats: [record.format],
          content_type: record.content_type,
          layout: false
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
      hash[:page] = ERB::Util.html_escape(render_to_string(view_for(true)))
      hash[:path] = parent_path(record) unless action_name == 'import'
      
      if (action_name == 'update' || action_name == 'create') && controller_name != 'test_scores'
        hash[:terms] = if record.class == Period
          ['All', record.term]
        elsif [Student, User].include?(record.class)
          ['All', 'With No Period'] + record.periods.pluck(:term)
        end
        
        if [Period, Student, User].include?(record.class)
          hash[:term_filter] = ERB::Util.html_escape render_to_string('_term_filter', layout: false)
        end
        hash[:row] = ERB::Util.html_escape(render_to_string('_row', layout: false))
      end
    end
  end
  
  # The object to return in case of a failure.
  def failure_hash
    {
      page: ERB::Util.html_escape(render_to_string(view_for(false))),
      success: false
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
      page: ERB::Util.html_escape(render_to_string('show'))
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