class AddColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :event_location, :string
  end
end
