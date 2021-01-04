class CreateSeatingCategories < ActiveRecord::Migration
  def change
    create_table :seating_categories do |t|
      t.string :category_name
      t.timestamps
    end
  end
end
