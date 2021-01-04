class CreateSpiritualPracticePhysicalExerciseTypeAssociations < ActiveRecord::Migration
  def change
    create_table :spiritual_practice_physical_exercise_type_associations do |t|
      t.integer :spiritual_practice_id
      t.integer :physical_exercise_type_id

      t.timestamps
    end
  end
end
