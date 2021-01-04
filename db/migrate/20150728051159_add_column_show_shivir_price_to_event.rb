class AddColumnShowShivirPriceToEvent < ActiveRecord::Migration
  def change
    add_column :events, :show_shivir_price, :boolean, :default => :false
  end
end
