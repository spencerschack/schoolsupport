module ExportHelper
  
  # The field name for the check boxes next to table rows on index pages.
  def export_attr resource
    @export_attr ||= "selected[#{resource.class.name.underscore}_ids][]"
  end
  
  # The title to display under 'PRINT'.
  def export_title
    if params[:export_type]
      if @export.type == 'print'
        @export.pdf.template.name
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
    if id = defined?(@export) ? @export.pdf.try(:id) : options[:id]
      path << "/#{id}"
    end
    if format = defined?(@export) ? @export.format : options[:format]
      path << ".#{format}"
    end
    path
  end
  
  # Which templates to show to the current user as options.
  def available_pdfs
    School.with_permissions_to(:show).includes(:pdfs).map(&:pdfs).flatten
  end
  
end