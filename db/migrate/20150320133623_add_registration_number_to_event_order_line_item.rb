class AddRegistrationNumberToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :registration_number, :integer
  end
end
