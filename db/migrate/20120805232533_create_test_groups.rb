class CreateTestGroups < ActiveRecord::Migration
  def change
    create_table :test_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
