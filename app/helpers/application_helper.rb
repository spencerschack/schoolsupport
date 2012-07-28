module ApplicationHelper
  
  # Initialize parents constant for storing types of parents for types of
  # records.
  ::PARENTS = {}
  
  # Initialize fields constant for storing which fields to show for types of
  # records.
  ::FIELDS = {}
  
  # Title to display on collection pages.
  def plural_title model = controller_model
    singular_title(model).pluralize
  end
  
  # Title to display on member pages.
  def singular_title model = controller_model
    (model.respond_to?(:display_name) ? model.display_name : model.model_name).titleize
  end
	
	# Return a render if applicable.
	def term_filter
	  if [Period, Student, User].include?(controller_model)
	    render 'term_filter'
    end
	end
	
	# Which terms can be selected.
	def term_options
	  if controller_model == Period
	    years = find_collection.uniq.pluck(:term)
	    other_options = ['All']
	    
    elsif [Student, User].include?(controller_model)
      record_ids = find_collection.pluck("#{controller_name}.id")
      periods = if record_ids.any?
        Period.joins(controller_name).where(controller_name => { id: record_ids })
      else
        []
      end
      years = periods.any? ? periods.uniq.pluck(:term) : []
      other_options = ['All', 'With No Period']
    end
    
    selected = params[:term] || Term.current
    (years << selected) unless years.include?(selected)
    years.sort!
    
    options_for_select(other_options) <<
    grouped_options_for_select([['By year', years]], selected)
	end
	
	# What to use for buttons that act on javascript events, not anchors.
	def js_link
	 'javascript:;'
	end
	
	# HTML classes to add to the page wrapper in xhr.html.haml.
	def page_classes
		[controller_name, action_name, 'wrapper'].join(' ')
	end
	
	# The fields to show for the action and the controller.
	def fields action, controller = nil
	  action = :index if action == :import
	  controller ||= controller_name.to_sym
	  FIELDS[controller][action]
	end
	
	# If there is nothing, this is what is displayed.
	def none
		'&mdash;'.html_safe
	end
	
	# Method for table headers.
	def header_content field
	 field.to_s.titleize
	end
	
	# For the given field on the given record, return the value or the value of
	# calling name if it can be called. If nil or a blank string was retrieved,
	# return the default representation of none.
	def cell_content record, field
	  content = record.send(field)
	  content = content.url if content.respond_to?(:url)
	  content = content.name if content.respond_to?(:name)
	  content.nil? || content == '' ? none : content.to_s
	end
	
	# Wrap cell_content in a paragraph with a bold title of the field.
	def field_content record, field
	  content = auto_link(cell_content(record, field))
	  content_tag(:p, content_tag(:b, field.to_s.titleize) << content)
	end
	
	# Create an appropriate link for the relation.
	def relation_content record, field
	  value = record.send(field)
	  case record.class.reflect_on_association(field).try(:macro)
    when :has_many, :has_and_belongs_to_many
      return unless permitted_to?(:index, field)
      value = value.with_term if value.respond_to?(:with_term)
      content = content_tag(:span, value.count)
      path = parent_path(field)
      title = title_from_field(field, true)
    when :belongs_to, :has_one
      return unless permitted_to?(:show, field)
      if name = value.try(:name)
        content, path = name, parent_path(value)
      else
        content, path = none, nil
      end
      title = title_from_field(field, false)
    end
    
    content = content_tag(:b, title) << content_tag(:span, content)
    path ? link_to(content, path) : content_tag(:a, content)
	end
	
	def title_from_field field, pluralize
	  model = field.to_s.singularize.camelize.constantize
	  pluralize ? plural_title(model) : singular_title(model)
	end
end
