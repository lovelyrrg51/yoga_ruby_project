class ChangeColumnNameInEventRegistration < ActiveRecord::Migration
  def change
    rename_column :event_registrations, :event_type_pring_id, :event_type_pricing_id
  end
end
