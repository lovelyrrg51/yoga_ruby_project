class AddDiscountTextColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :discount_text, :text, default: ''
  end
end
