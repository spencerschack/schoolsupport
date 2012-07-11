module ExportHelper
  
  # The field name for the check boxes next to table rows on index pages.
  def export_attr resource
    "selected[#{resource.class.name.underscore}_ids][]"
  end
  
  # The title to display under 'EXPORT'.
  def export_title
    if params[:export_type]
      if @export.type == 'print'
        @export.template.name
      else
        @export.type.titleize
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
    if type = defined?(@export) ? @export.type : options[:type]
      path << "/#{type}"
    end
    if id = defined?(@export) ? @export.template.try(:id) : options[:id]
      path << "/#{id}"
    end
    if format = defined?(@export) ? @export.format : options[:format]
      path << ".#{format}"
    end
    path
  end
  
  # Which templates to show to the current user as options.
  def available_templates
    Template.find(School.with_permissions_to(:show).map(&:template_ids))
  end
  
end