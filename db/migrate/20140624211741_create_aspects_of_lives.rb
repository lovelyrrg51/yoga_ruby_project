class CreateAspectsOfLives < ActiveRecord::Migration
  def change
    create_table :aspects_of_lives do |t|
      t.string :benefits_to_family
      t.string :other_areas_of_improvement
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
