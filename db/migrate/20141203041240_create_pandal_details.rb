class CreatePandalDetails < ActiveRecord::Migration
  def change
    create_table :pandal_details do |t|
      t.decimal :length, precision: 10, scale: 2
      t.decimal :width, precision: 10, scale: 2
      t.integer :seating_type
      t.integer :matresses_count
      t.integer :chairs_count
      t.text :arrangement_details
      t.integer :event_id
      
      t.foreign_key :events, dependent: :delete
      t.timestamps
    end
  end
end
