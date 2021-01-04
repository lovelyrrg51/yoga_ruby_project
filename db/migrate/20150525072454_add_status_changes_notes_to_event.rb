class AddStatusChangesNotesToEvent < ActiveRecord::Migration
  def change
    add_column :events, :status_changes_notes, :text
  end
end
