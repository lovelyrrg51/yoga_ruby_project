class AddSlugToEventOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :event_orders, :slug, :string
    add_index :event_orders, :slug, unique: true
  end
end
