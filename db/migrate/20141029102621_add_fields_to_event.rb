class AddFieldsToEvent < ActiveRecord::Migration
  def change
    add_column :events, :graced_by, :string
    add_column :events, :contact_details, :string
    add_column :events, :video_url, :text
    add_column :events, :demand_draft_instructions, :text
  end
end
