class CreateEventPrerequisitesEventTypes < ActiveRecord::Migration
  def change
    create_table :event_prerequisites_event_types do |t|
      t.references :event, index: true
      t.references :event_type, index: true

      t.timestamps
    end
  end
end
