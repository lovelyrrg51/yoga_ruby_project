class AddMasterEventIdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :master_event_id, :integer
  end
end
