class CreateShivyogEvents < ActiveRecord::Migration
  def change
    create_table :shivyog_events do |t|
      t.string :event_name
      t.datetime :event_start_datetime
      t.datetime :event_end_datetime
      t.string :event_location_type  #for online/virtual/physicial
      t.string :event_location
      t.string :event_content_type #for mata ki chowki, satsaang, DSS, etc
      t.integer :creator_user_id  #must be an Ashram admin
      t.integer :organizer_user_id  #can be any trained user
      
      t.timestamps
    end
  end
end
