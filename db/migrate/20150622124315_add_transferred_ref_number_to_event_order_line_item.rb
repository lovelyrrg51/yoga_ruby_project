class AddTransferredRefNumberToEventOrderLineItem < ActiveRecord::Migration
  def change
    add_column :event_order_line_items, :transferred_ref_number, :string
  end
end
