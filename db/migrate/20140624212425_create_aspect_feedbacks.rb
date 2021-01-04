class CreateAspectFeedbacks < ActiveRecord::Migration
  def change
    create_table :aspect_feedbacks do |t|
      t.integer :aspect_type # contains type of aspect
      t.integer :rating_before #limit to 5 point scale
      t.string :descripton_before
      t.integer :rating_after #limit to 5 point scale
      t.string :description_after
      t.integer :aspects_of_life_id

      t.timestamps
    end
  end
end
