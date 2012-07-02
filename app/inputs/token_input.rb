class TokenInput < Formtastic::Inputs::CheckBoxesInput
  
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
  
  alias_method :choice_wrapping_html_options_super, :choice_wrapping_html_options
  # Add school id to choice wrapping.
  def choice_wrapping_html_options(choice)
    super_options = choice_wrapping_html_options_super(choice)
    if reflection
      %w(school_id district_id).each do |column|
        if reflection.klass.column_names.include?(column)
          return super_options.merge({data: {
            depends_on: column,
            depends_id: reflection.klass.find(choice.last).send(column)
          }})
        end
      end
    else
      super_options
    end
  end
  
end