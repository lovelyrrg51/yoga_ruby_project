class AddEventTypePricingIdToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_reference :event_order_line_items, :event_type_pricing, index: true
  end
end
