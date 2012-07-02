class SchoolInput < Formtastic::Inputs::SelectInput
  
  def collection
    District.with_permissions_to(:show).map do |district|
      [district.name, district.schools.map do |school|
        [school.name, school.id, {
          'data-district-id' => district.id,
          'data-school-id' => school.id
        }]
      end]
    end.reject { |district| district.last.empty? }
  end
  
end