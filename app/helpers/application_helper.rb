module ApplicationHelper
  
  # Initialize parents constant for storing types of parents for types of
  # records.
  ::PARENTS = {}
  
  # Initialize fields constant for storing which fields to show for types of
  # records.
  ::FIELDS = {}
  
  ::SORTS = {}
  
  # Title to display on collection pages.
  def plural_title model = controller_model
    singular_title(model).pluralize
  end
  
  # Title to display on member pages.
  def singular_title model = controller_model
    (model.respond_to?(:display_name) ? model.display_name : model.model_name).titleize
  end
	
	# Which terms can be selected.
	def term_options
	  return if find_first_parent.is_a?(Period)
	  @term_options ||= begin
  	  other_options = [['All Terms', 'All']]
  	  if controller_model == Period
        terms = options_scope.uniq.pluck("#{controller_name}.term")
      elsif [Student, User].include?(controller_model)
        other_options << 'With No Period'
        terms = options_scope.joins(:periods).uniq.pluck('periods.term')
      elsif controller_model == TestScore
        terms = options_scope.uniq.pluck('test_scores.term')
      end
      selected = if !params[:term]
        'All'
      else
        terms << params[:term] unless terms.include? params[:term]
        params[:selected]
      end
    
      options_for_select(other_options) <<
      options_for_select(terms.sort, selected)
    end
	end
	
	def grade_options
	 @grade_options ||= if controller_model == Student
	   grades = if controller_model == Student
	     options_scope.uniq.pluck('students.grade')
	   elsif controller_model == TestScore
	     options_scope.joins(:student).uniq.pluck('students.grade')
     end
     selected = params[:grade].present? ? params[:grade] : 'All'
	   grades.sort_by!(&:to_i)
	   options_for_select([['All Grades', 'All']] + grades, selected)
   end
	end
	
	# Includes an include_blank option.
	def import_prompt_options args
	  options = args.extract_options!
	  options.reverse_merge! include_blank: true
	  [*args, options]
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
	
	# Method for the order by statement for a specific column.
	def order_by_for field
	  if (order = SORTS[controller_name.to_sym].try(:[], field)) || controller_model.column_names.include?(field.to_s)
	    order ||= "#{controller_model.table_name}.#{field}"
	    " data-order-by=\"#{order}\" class=\"sortable\"".html_safe
    end
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
	  association = record.class.reflect_on_association(field)
	  case association.try(:macro)
    when :has_many, :has_and_belongs_to_many
      return unless permitted_to?(:index, field)
      content = content_tag(:span, value.count)
      path = parent_path(field)
      title = title_from_field(field, true)
    when :belongs_to, :has_one
      return unless permitted_to?(:show, field)
      if name = value.try(:name)
        content = name
        path = field == :parent ? nil : parent_path(value)
      else
        content, path = none, nil
      end
      title = title_from_field(field, false)
    end
    
    content = content_tag(:b, title) << content_tag(:span, content)
    path ? link_to(content, path) : content_tag(:a, content)
	end
	
	def title_from_field field, pluralize
	  return pluralize ? 'Parents' : 'Parent' if field == :parent
	  model = field.to_s.singularize.camelize.constantize
	  pluralize ? plural_title(model) : singular_title(model)
	end
	
	private
	
	def options_scope
	 @options_scope ||= if find_first_parent
	   find_first_parent.send(controller_name)
	  else
	    controller_model
    end.with_permissions_to(:show)
	end
	
end
