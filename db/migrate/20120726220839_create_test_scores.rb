class CreateTestScores < ActiveRecord::Migration
  def change
    create_table :test_scores do |t|
      t.integer :student_id
      t.integer :test_model_id
      t.string :term

      t.timestamps
    end
  end
end
