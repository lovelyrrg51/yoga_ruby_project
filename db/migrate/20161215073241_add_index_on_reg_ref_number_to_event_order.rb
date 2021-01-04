class AddIndexOnRegRefNumberToEventOrder < ActiveRecord::Migration
  def change
    add_index :event_orders, :reg_ref_number, unique: true
  end
end
