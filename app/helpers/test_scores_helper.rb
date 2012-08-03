module TestScoresHelper
  
  PARENTS[:test_scores] = [TestModel, Student, Period, User, School, District]
  
  FIELDS[:test_scores] = {
    show: { fields: [:term], relations: [:student, :test_model] }
  }
  
  def ordered_scores test_scores
    unordered = test_scores.each_with_object({}) do |test_score, hash|
      @test_models << test_score.test_model
      hash.merge! test_score.test_model => test_score
    end
    @test_models.map do |test_model|
      unordered[test_model]
    end
  end
  
end
