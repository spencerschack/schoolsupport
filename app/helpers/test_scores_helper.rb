module TestScoresHelper
  
  PARENTS[:test_scores] = [Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    index: [:student, :test_model, :term],
    show: { fields: [:term], relations: [:student, :test_model] },
    form: { fields: [:term], relations: [[:student, as: :token], :test_model] }
  }
  
end
