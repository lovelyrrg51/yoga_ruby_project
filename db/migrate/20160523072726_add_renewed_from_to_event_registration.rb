class AddRenewedFromToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :renewed_from, :integer
  end
end
