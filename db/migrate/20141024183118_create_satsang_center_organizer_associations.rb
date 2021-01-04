class CreateSatsangCenterOrganizerAssociations < ActiveRecord::Migration
  def change
    create_table :satsang_center_organizer_associations do |t|
      t.integer :satsang_center_id
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
