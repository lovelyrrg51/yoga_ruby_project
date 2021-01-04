class CreateEventOrderVersion < ActiveRecord::Migration
	TEXT_BYTES = 1_073_741_823
  def change
    create_table :event_order_versions do |t|
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
    add_index :event_order_versions, [:item_type, :item_id]
  end
end
