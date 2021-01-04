class AddGuestEmailToEventOrders < ActiveRecord::Migration
  def change
    add_column :event_orders, :guest_email, :string
  end
end
