module ApplicationHelper
  
  # Initialize parents constant for storing types of parents for types of
  # records.
  ::PARENTS = {}
  
  # Initialize fields constant for storing which fields to show for types of
  # records.
  ::FIELDS = {}
	
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
      periods = Period.joins(controller_name).where(controller_name => { id: record_ids })
      years = periods.uniq.pluck(:term)
      other_options = ['All', 'With No Period']
    end
    
    selected = params[:term] || Period.current_term
    (years << selected).sort! unless years.include?(selected)
    
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
	  content = record.try(field)
	  content = content.url if content.respond_to?(:url)
	  content = content.name if content.respond_to?(:name)
	  content.nil? || content == '' ? none : auto_link(content.to_s)
	end
	
	# Wrap cell_content in a paragraph with a bold title of the field.
	def field_content record, field
	  content = cell_content(record, field)
	  content_tag(:p, content_tag(:b, field.to_s.titleize) << content)
	end
	
	# Create an appropriate link for the relation.
	def relation_content record, field
	  case record.class.reflect_on_association(field).try(:macro)
    when :has_many, :has_and_belongs_to_many
      content = content_tag(:span, record.send(field).count)
      path = parent_path(field)
    when :belongs_to, :has_one
      value = record.send(field)
      if name = value.try(:name)
        content, path = name, parent_path(value)
      else
        content, path = none, nil
      end
    end
   
    link_to path do
      content_tag(:b, field.to_s.titleize) <<
      content_tag(:span, content)
    end
	end
end
