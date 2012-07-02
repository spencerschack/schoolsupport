class BusInput < Formtastic::Inputs::SelectInput
  
  def include_blank
    true
  end
  
  def collection
    selected = @object && @object.send(method)
    District.with_permissions_to(:show).map do |district|
      if (records = district.send(method.to_s.pluralize)).present?
        template.content_tag(:optgroup,
          records.map do |record|
            options = { value: record.id }
            options.merge!(selected: 'selected') if record.id == selected
            template.content_tag(:option, record.name, options)
          end.join("\n").html_safe, {
          :label => district.name,
          'data-depends-on' => 'district_id',
          'data-depends-id' => district.id
        })
      end
    end.compact.join("\n").html_safe
  end
  
end