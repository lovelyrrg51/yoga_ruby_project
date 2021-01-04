class CreateActivityEventTypePricingAssociations < ActiveRecord::Migration
  def change
    create_table :activity_event_type_pricing_associations do |t|
      t.references :event, index: true
      t.references :event_type_pricing

      t.timestamps
    end
    add_index :activity_event_type_pricing_associations, [ :event_type_pricing_id ], name: 'index_activity_pricing_associations_on_event_type_pricing_id'
  end
end
