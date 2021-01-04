class ChnagesTierTypeInEventTypePricing < ActiveRecord::Migration
  def change
    change_column :event_type_pricings, :tier_type, :string
  end
end
