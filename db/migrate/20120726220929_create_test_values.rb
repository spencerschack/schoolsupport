class CreateTestValues < ActiveRecord::Migration
  def change
    create_table :test_values do |t|
      t.integer :test_score_id
      t.integer :test_attribute_id
      t.string :value

      t.timestamps
    end
  end
end
