class AddEventSeatingCategoryAssociationIdToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :event_seating_category_association_id, :integer
  end
end
