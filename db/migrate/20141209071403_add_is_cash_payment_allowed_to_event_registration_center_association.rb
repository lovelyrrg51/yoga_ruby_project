class AddIsCashPaymentAllowedToEventRegistrationCenterAssociation < ActiveRecord::Migration
  def change
    add_column :event_registration_center_associations, :is_cash_payment_allowed, :boolean, :default => false
  end
end
