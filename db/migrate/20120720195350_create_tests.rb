class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.string :type
      t.text :data
      t.string :term
      t.integer :student_id

      t.timestamps
    end
  end
end
