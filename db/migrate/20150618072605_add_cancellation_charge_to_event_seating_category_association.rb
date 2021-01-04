class AddCancellationChargeToEventSeatingCategoryAssociation < ActiveRecord::Migration
  def change
    add_column :event_seating_category_associations, :cancellation_charge, :float, precision: 5, scale: 2
  end
end
