class AddDeatilsToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :is_extra_seat, :boolean, default: false
  end
end
