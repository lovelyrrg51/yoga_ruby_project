class CreateEventTypePricings < ActiveRecord::Migration
  def change
    create_table :event_type_pricings do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.integer :tier_type
      t.references :event_type
      t.foreign_key :event_types, column: :event_type_id
      t.timestamps
    end
  end
end
