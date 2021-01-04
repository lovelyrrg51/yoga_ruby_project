class AddFieldsToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :status, :integer
    add_column :event_orders, :total_amount, :decimal
    add_column :event_orders, :final_line_items, :string
    add_column :event_orders, :payment_gateway_response, :text
  end
end
