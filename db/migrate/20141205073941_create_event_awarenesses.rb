class CreateEventAwarenesses < ActiveRecord::Migration
  def change
    create_table :event_awarenesses do |t|
      t.references :event_awareness_type, index: true
      t.references :event, index: true
      t.decimal :budget, precision: 10, scale: 2
      t.string :event_awareness_type_name
      
      t.foreign_key :events, dependent: :delete
      t.foreign_key :event_awareness_types
      t.timestamps
    end
  end
end
