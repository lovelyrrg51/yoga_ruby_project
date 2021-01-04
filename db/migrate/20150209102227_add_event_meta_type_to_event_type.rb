class AddEventMetaTypeToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :event_meta_type, :integer
  end
end
