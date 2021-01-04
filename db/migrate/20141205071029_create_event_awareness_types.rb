class CreateEventAwarenessTypes < ActiveRecord::Migration
  def change
    create_table :event_awareness_types do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
