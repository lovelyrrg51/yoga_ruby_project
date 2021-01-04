class CreateCannonicalEvents < ActiveRecord::Migration
  def change
    create_table :cannonical_events do |t|
      t.string :event_name
      t.string :event_meta_type  # virtual / physical / live
      t.timestamps
    end
  end
end
