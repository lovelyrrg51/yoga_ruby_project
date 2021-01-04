class CreatePhysicalExerciseTypes < ActiveRecord::Migration
  def change
    create_table :physical_exercise_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
