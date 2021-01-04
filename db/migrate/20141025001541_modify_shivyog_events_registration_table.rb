class ModifyShivyogEventsRegistrationTable < ActiveRecord::Migration
  def change
    remove_column :shivyog_event_registrations, :amount_paid
    remove_column :shivyog_event_registrations, :payment_vehicle
    remove_column :shivyog_event_registrations, :payment_identification_number
    remove_column :shivyog_event_registrations, :seating_type
    add_column :shivyog_event_registrations, :seating_category_id, :integer
    add_column :shivyog_event_registrations, :sadhak_profile_id, :integer
  end
end
