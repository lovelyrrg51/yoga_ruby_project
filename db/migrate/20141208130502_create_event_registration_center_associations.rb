class CreateEventRegistrationCenterAssociations < ActiveRecord::Migration
  def change
    create_table :event_registration_center_associations do |t|
      t.references :event
      t.references :registration_center
      
      t.foreign_key :events, name: :fk_erca_event
      t.foreign_key :registration_centers, name: :fk_erca_rgn_center
      
      t.timestamps
    end
  end
end
