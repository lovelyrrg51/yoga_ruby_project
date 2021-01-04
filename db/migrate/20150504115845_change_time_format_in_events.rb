class ChangeTimeFormatInEvents < ActiveRecord::Migration
  def change
    change_column :events, :event_start_time, :string
    change_column :events, :event_end_time, :string
  end
end
