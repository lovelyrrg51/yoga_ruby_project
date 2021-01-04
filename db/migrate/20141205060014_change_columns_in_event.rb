class ChangeColumnsInEvent < ActiveRecord::Migration
  def change
    rename_column :events, :event_start_datetime, :event_start_date
    rename_column :events, :event_end_datetime, :event_end_date
    change_column :events, :event_start_date, :date
    change_column :events, :event_end_date, :date
    add_column :events, :event_start_time, :time
    add_column :events, :event_end_time, :time
    add_column :events, :additional_details, :text
  end
end
