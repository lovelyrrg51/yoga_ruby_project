class CreateEventSeatingCategoryAssociationVersion < ActiveRecord::Migration
  TEXT_BYTES = 1_073_741_823
  def change
    create_table :event_seating_category_association_versions do |t|
      t.string     :item_type, :null => false
      t.integer    :item_id,   :null => false
      t.string     :event,     :null => false
      t.text       :object,    :limit => TEXT_BYTES
      t.string     :ip
      t.float      :latitude
      t.float      :longitude
      t.string     :whodunnit
      t.datetime   :created_at
    end
    add_index :event_seating_category_association_versions, [:item_type, :item_id], name: 'index_event_category_ass_versions_on_item_type_and_item_id'
  end
end
