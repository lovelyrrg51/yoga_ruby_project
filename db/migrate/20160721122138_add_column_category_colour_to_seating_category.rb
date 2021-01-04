class AddColumnCategoryColourToSeatingCategory < ActiveRecord::Migration
  def change
    add_column :seating_categories, :category_colour, :string
  end
end
