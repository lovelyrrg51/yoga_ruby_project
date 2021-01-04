class AddSeatingCapacityToEventSeatingCategoryAssociation < ActiveRecord::Migration
  def change
    add_column :event_seating_category_associations, :seating_capacity, :integer
  end
end
