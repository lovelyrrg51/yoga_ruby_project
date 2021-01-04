class AddRegRefNumberToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :reg_ref_number, :string
  end
end
