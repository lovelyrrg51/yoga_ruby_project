class AddStatusToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :status, :integer
  end
end
