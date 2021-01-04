class CreateEventSeatingCategoryAssociations < ActiveRecord::Migration
  def change
    create_table :event_seating_category_associations do |t|
      t.integer :shivyog_event_id
      t.integer :seating_category_id
      t.decimal :price
      t.timestamps
    end
  end
end
