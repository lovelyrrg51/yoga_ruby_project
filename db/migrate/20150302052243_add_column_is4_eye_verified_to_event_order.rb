class AddColumnIs4EyeVerifiedToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :is_4_eye_verified, :boolean, :default => false
    add_column :event_orders, :is_guest_user, :boolean, :default => false
  end
end
