class AddColumnIsDeletedToEventRegistration < ActiveRecord::Migration
  def change
    add_column :event_registrations, :is_deleted, :boolean, default: false
  end
end
