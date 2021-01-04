class DropTableHistoricalEvents < ActiveRecord::Migration[5.2]
  def up
    drop_table :historical_events
  end

  def down
    create_table "historical_events", id: :serial, force: :cascade do |t|
      t.string :event_type
      t.integer :month
      t.integer :year
      t.integer :city
      t.integer :country
      t.integer :shivyog_journey_id
      t.integer :event_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
