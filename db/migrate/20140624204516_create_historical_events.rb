class CreateHistoricalEvents < ActiveRecord::Migration
  def change
    create_table :historical_events do |t|
      t.string :event_type
      t.integer :month
      t.integer :year
      t.string :city
      t.string :country
      t.integer :shivyog_event_id
      t.integer :shivyog_journey_id
      t.timestamps
    end
  end
end
