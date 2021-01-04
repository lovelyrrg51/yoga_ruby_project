class AddEventTypePricingIdToEventRegistration < ActiveRecord::Migration
  def change
    add_reference :event_registrations, :event_type_pring, index: true
  end
end
