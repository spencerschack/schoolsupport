module LinkHelper
  
  # Creates a link to the given method with the passed.
	def collection_link_for record, method
	  link_to parent_path(method), class: 'collection_link' do
	    method.to_s.titleize.html_safe <<
	    content_tag(:span, record.send(method).count)
    end if permitted_to?(:index, method)
	end
	
	# Creates a link to the given method with the passed record.
	def record_link_for record, field
	  record = record.send(field)
	  path = parent_path(record) rescue nil
	  if path && permitted_to?(:show, record)
	    link_to path, class: 'record_link' do
	      field.to_s.titleize.html_safe <<
	      content_tag(:span, record.name)
      end
    else
      content_tag :div, class: 'record_link' do
        field.to_s.titleize.html_safe <<
        content_tag(:span, record.name)
      end
    end
	end
	
	# Generates a link for the given action and model_or_record and returns it
	# only if the current user is allowed to visit that link.
	def link_for *args
	  options = args.extract_options!
	  action = args.length > 1 ? args.first.to_sym : :show
	  model_or_record = args.last
	  
	  classes = (options[:class] || '').split(' ')
	  classes << if model_or_record.respond_to?(:model_name)
	    model_or_record.model_name
	  else
	    model_or_record.class
    end.to_s.underscore
    classes << action
    options[:class] = classes.join(' ')
	  
		case action
	  when :index
	    return unless permitted_to? action, model_or_record
      link_to model_or_record.model_name.titleize.pluralize,
        parent_path(model_or_record), options
	    
    when :show
      link_to_if permitted_to?(action, model_or_record),
        model_or_record.name.titleize, parent_path(model_or_record), options
        
    when :edit
      return unless permitted_to? action, model_or_record
        link_to 'Edit', js_link, options
      
    when :update
      link_to 'Save', js_link, options
      
    when :new
      return unless permitted_to? action, model_or_record
      link_to 'New', parent_path(model_or_record, { action: :new }), options
      
    when :create
      link_to 'Create', js_link, options
      
    when :destroy
      return unless permitted_to? action, model_or_record
      link_to 'Delete', js_link, options.merge(data: {
        path: polymorphic_path(model_or_record)})
      
    when :cancel
      link_to 'Cancel', js_link, options
      
    when :search
      link_to 'Search', js_link, options
      
    when :print
      return unless permitted_to? :print, model_or_record
      if model_or_record.is_a?(Class) && (model_or_record == Student ||
        model_or_record.reflect_on_association(:students))
          link_to 'Print', js_link, options
          
      elsif model_or_record.is_a?(Student) ||
        model_or_record.respond_to?(:students)
          options.merge!(
            name: "print_job[#{model_or_record.class.name.underscore}_ids][]",
            value: model_or_record.id
          )
          link_to 'Print', js_link, options
      end
      
    when :import
      if permitted_to?(action, model_or_record) && Import.for?(model_or_record)
        link_to 'Import', js_link, options
      end
      
    when :upload
      link_to 'Upload', js_link, options
    end
	end
  
end