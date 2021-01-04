class AddColumnEntityTypeAndEntityKeyToEvent < ActiveRecord::Migration
  def change
    add_column :events, :entity_type, :integer
    add_column :events, :entity_key, :string
  end
end
