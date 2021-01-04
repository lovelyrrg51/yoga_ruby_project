class AddReferenceEventIdToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :reference_event_id, :integer
  end
end
