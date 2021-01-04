class CreateEventOrderLineItems < ActiveRecord::Migration
  def change
    create_table :event_order_line_items do |t|
      t.integer :event_order_id
      t.integer :sadhak_profile_id
      t.integer :seating_category_id
      t.decimal :price
      t.timestamps
    end
  end
end
