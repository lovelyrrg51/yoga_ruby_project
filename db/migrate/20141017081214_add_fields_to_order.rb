class AddFieldsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :final_line_items, :string
    add_column :orders, :sbm_order_id, :string
    add_column :orders, :sbm_merchant_order_num, :string
    add_column :orders, :sbm_amount_paid, :string
    add_column :orders, :sbm_response, :text
  end
end
