class AddColumnPrerequisiteMessageToEvent < ActiveRecord::Migration
  def change
    add_column :events, :prerequisite_message, :text
  end
end
