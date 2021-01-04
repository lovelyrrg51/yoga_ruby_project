class CreateEventTaxTypeAssociations < ActiveRecord::Migration
  def change
    create_table :event_tax_type_associations do |t|
      t.float :percent, precision: 5, scale: 2
      t.integer :sequence
      t.references :event, index: true
      t.references :tax_type, index: true

      t.timestamps
    end
  end
end
