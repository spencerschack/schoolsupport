module ApplicationHelper
  
  # Initialize parents constant for storing types of parents for types of
  # records.
  ::PARENTS = {}
  
  # Initialize fields constant for storing which fields to show for types of
  # records.
  ::FIELDS = {}
  
  def print_job_attr resource
    "print_job[#{resource.class.name.underscore}_ids][]"
  end
	
	# What to use for buttons that act on javascript events, not anchors.
	def js_link
	 'javascript:;'
	end
	
	# HTML classes to add to the page wrapper in xhr.hmtl.haml.
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
	
	# For the given field on the given record, return the value or the value of
	# calling name if it can be called. If nil or a blank string was retrieved,
	# return the default representation of none.
	def field_content record, field
	  content = record.send(field)
	  content = content.name if record.class.reflect_on_association(field)
	  content.present? ? content.to_s : none
	end
	
	def show_content record, field
	  case record.class.reflect_on_association(field).try(:macro)
    when nil
      content = if field == :image || field == :file
        file = record.send(field)
        link_to image_tag(file.url(:thumbnail)), file.url
      else
        auto_link(field_content(record, field))
      end
      content_tag(:p,
        content_tag(:b, field.to_s.titleize) <<
        content,
        class: 'show_content'
      )
    when :has_many, :has_and_belongs_to_many
      collection_link_for record, field
    when :belongs_to, :has_one
      record_link_for record, field
    end
	end
end
