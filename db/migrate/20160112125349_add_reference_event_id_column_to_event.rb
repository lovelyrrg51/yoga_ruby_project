class AddReferenceEventIdColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :reference_event_id, :integer
  end
end
