class AddColumnNotificationServiceToEvent < ActiveRecord::Migration
  def change
    add_column :events, :notification_service, :boolean, default: true
  end
end
