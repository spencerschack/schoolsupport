class CreateTestAttributes < ActiveRecord::Migration
  def change
    create_table :test_attributes do |t|
      t.string :name

      t.timestamps
    end
  end
end
