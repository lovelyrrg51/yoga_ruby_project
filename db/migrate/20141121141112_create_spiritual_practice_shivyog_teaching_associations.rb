class CreateSpiritualPracticeShivyogTeachingAssociations < ActiveRecord::Migration
  def change
    create_table :spiritual_practice_shivyog_teaching_associations do |t|
      t.integer :spiritual_practice_id
      t.integer :shivyog_teaching_id

      t.timestamps
    end
  end
end
