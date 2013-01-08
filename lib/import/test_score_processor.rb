class TestScoreProcessor
  
  def self.call hash, import_data
    model = import_data.model
    
    # Associate the student because has_import does not have an option to
    # associate with a scope (school) because student identifiers are only
    # guaranteed to be unique in a school. Also necessary because school
    # would be added to the data column in the code below if not removed here. 
    school = School.where(identifier: hash.delete(:school)).first!
    hash[:student_id] = school.students.where(identifier: hash.delete(:student)).first!.id
    
    # Ensure all test names are lowercase so we don't have duplicate test
    # called 'Ela' and 'ela'.
    hash[:test_name].downcase!
    
    # Put all columns present in the hash but not present in the model in
    # the serialized data column. Also ensure that all keys are lowercase
    # to prevent duplicate keys like 'Ela' and 'ela'.
    hash[:data] = {}
    hash.each do |key, value|
      unless model.column_names.include?(key.to_s)
        hash.delete(key)
        hash[:data][key.downcase] = value
      end
    end
  end
  
end