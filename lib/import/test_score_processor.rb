class TestScoreProcessor
  
  def self.call hash, import_data
    model = import_data.model
    school = School.where(identifier: hash.delete(:school)).first!
    hash[:student_id] = school.students.where(identifier: hash.delete(:student)).first!.id
    hash[:data] = {}
    hash.each do |key, value|
      unless model.column_names.include?(key.to_s)
        hash.delete(key)
        hash[:data][key] = value
      end
    end
  end
  
end