class AddCodeToEventType < ActiveRecord::Migration
  def change
    add_column :event_types, :code, :string
  end
end
