class CreateEventOrders < ActiveRecord::Migration
  def change
    create_table :event_orders do |t|
      t.integer :shivyog_event_id
      t.integer :user_id
      t.integer :rc_user_id
      t.timestamps
    end
  end
end
