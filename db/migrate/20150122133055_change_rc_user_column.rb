class ChangeRcUserColumn < ActiveRecord::Migration
  def change
    rename_column :event_orders, :rc_user_id, :registration_center_user_id
  end
end
