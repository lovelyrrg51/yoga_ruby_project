class AddExpiresAtToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :expires_at, :integer
  end
end
