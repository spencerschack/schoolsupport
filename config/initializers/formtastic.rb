Formtastic::FormBuilder.include_blank_for_select_by_default = false

module Formtastic::Helpers::InputHelper
  
  # Return whether the current user is allowed to edit the given field.
  def allowed_to_edit method
    @allowed_to_edit ||= begin
      return true unless @object.class.respond_to? :accessible_attributes
      field = association_primary_key_for_method(method) || method
      role = Authorization.current_user.role_symbols.first
      @object.class.accessible_attributes(role).include?(field)
    end
  end
  
  alias_method :input_super, :input
  # Return nothing if not allowed to edit.
  def input method, options = {}
    input_super(method, options) if allowed_to_edit(method)
  end
  
  alias_method :default_input_type_super, :default_input_type
  # Make the default collection input type for has_many and habtm associations
  # check boxes.
  def default_input_type method, options = {}
    if @object && association_macro_for_method(method) =~ /^has/
      :check_boxes
    else
      default_input_type_super(method, options)
    end
  end
  
end

class Formtastic::Inputs::CheckBoxesInput
  
  # Add search field.
  def choices_group_wrapping(&block)
    template.content_tag(:ol,
      template.capture(&block) <<
      template.content_tag(:li,
        template.text_field_tag(nil),
        class: 'search_field'
      ),
      choices_group_wrapping_html_options
    ) << template.content_tag(:ol, '', class: 'results')
  end
  
  # Add icon for clear button.
  def choice_html(choice)
    template.content_tag(:label,
      hidden_fields? ?
        check_box_with_hidden_input(choice) :
        check_box_without_hidden_input(choice) <<
      choice_label(choice) <<
      template.content_tag(:i),
      label_html_options.merge(:for => choice_input_dom_id(choice), :class => nil)
    )
  end
  
end

module Formtastic::Inputs::Base::Choices
  
  alias_method :choice_wrapping_html_options_super, :choice_wrapping_html_options
  # Add school id to choice wrapping.
  def choice_wrapping_html_options(choice)
    super_options = choice_wrapping_html_options_super(choice)
    if reflection && reflection.klass.column_names.include?('school_id')
      super_options.merge({
        data: { school_id: reflection.klass.find(choice.last).school_id }
      })
    else
      super_options
    end
  end
  
end

module Formtastic::Inputs::Base
  
  # For collections, only show options that the current user can see.
  def collection_from_association
    super.tap do |records|
      if records.respond_to?(:with_permissions_to)
        records.with_permissions_to(:show)
      end
    end
  end
        
end