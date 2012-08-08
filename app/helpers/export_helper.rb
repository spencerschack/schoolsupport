module ExportHelper
  
  # The field name for the check boxes next to table rows on index pages.
  def export_attr model = controller_model
    @export_attr ||= "selected[#{model.name.underscore}_ids][]"
  end
  
  # The title to display under 'PRINT'.
  def export_title
    if params[:export_kind]
      Rails.logger.debug @export
      if @export.kind == 'print'
        @export.template.name
      else
        @export.kind.titleize
      end
    else
      if params[:id]
        controller_name.singularize
      else
        controller_name
      end.titleize
    end
  end
  
  # Curry parent_path for exports.
  def export_path options = {}
    path = parent_path(resource || controller_model, { action: :export })
    if kind = defined?(@export) ? @export.kind : options[:kind]
      path << "/#{kind}"
    end
    if id = defined?(@export) ? @export.type.try(:id) : options[:id]
      path << "/#{id}"
    end
    if format = defined?(@export) ? @export.format : options[:format]
      path << ".#{format}"
    end
    path
  end
  
  # Which templates to show to the current user as options.
  def available_types
    School.with_permissions_to(:show).includes(:types).map(&:types).flatten
  end
  
end