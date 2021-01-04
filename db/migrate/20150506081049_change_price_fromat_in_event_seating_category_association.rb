class ChangePriceFromatInEventSeatingCategoryAssociation < ActiveRecord::Migration
  def change
    change_column :event_seating_category_associations, :price, :decimal, precision: 10, scale: 3
  end
end
