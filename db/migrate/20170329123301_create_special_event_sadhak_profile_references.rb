class CreateSpecialEventSadhakProfileReferences < ActiveRecord::Migration
  def change
    create_table :special_event_sadhak_profile_references do |t|
      t.references :special_event_sadhak_profile_other_info
      t.references :sadhak_profile
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :special_event_sadhak_profile_references, :deleted_at
    add_index :special_event_sadhak_profile_references, :special_event_sadhak_profile_other_info_id, name: 'fk_special_event_sp_other_info_to_references'
    add_index :special_event_sadhak_profile_references, :sadhak_profile_id, name: 'fk_sadhak_id_on_special_event_sadhak_profile_references'
  end
end
