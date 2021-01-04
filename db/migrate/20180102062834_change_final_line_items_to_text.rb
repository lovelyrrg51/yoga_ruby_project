class ChangeFinalLineItemsToText < ActiveRecord::Migration[5.1]
  def change
    change_column :event_orders, :final_line_items, :text
  end
end
