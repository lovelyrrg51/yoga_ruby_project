class AddUniqnessAndNotNullToEventOrder < ActiveRecord::Migration
  def change
    change_column :event_orders, :reg_ref_number, :string, :null => false, unique: true
  end
end
