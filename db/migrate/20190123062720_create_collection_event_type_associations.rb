class CreateCollectionEventTypeAssociations < ActiveRecord::Migration[5.1]
  def change
    create_table :collection_event_type_associations do |t|
      t.string :sadhak_profile_ids
      t.references :collection, foreign_key: true
      t.references :event_type, foreign_key: true

      t.timestamps
    end
  end
end
