class AddEndDateIgnoredToEvent < ActiveRecord::Migration
  def change
    add_column :events, :end_date_ignored, :boolean, default: false
  end
end
