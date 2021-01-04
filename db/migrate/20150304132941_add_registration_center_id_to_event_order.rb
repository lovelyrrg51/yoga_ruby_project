class AddRegistrationCenterIdToEventOrder < ActiveRecord::Migration
  def change
    add_column :event_orders, :registration_center_id, :integer
  end
end
