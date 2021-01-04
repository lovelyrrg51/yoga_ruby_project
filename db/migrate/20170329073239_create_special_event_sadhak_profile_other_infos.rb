class CreateSpecialEventSadhakProfileOtherInfos < ActiveRecord::Migration
  def change
    create_table :special_event_sadhak_profile_other_infos do |t|
      t.references :sadhak_profile
      t.references :event_order_line_item
      t.references :event
      t.string :father_name
      t.string :mother_name
      t.boolean :are_you_member_of_political_party
      t.string :political_party_name
      t.string :how_long_associated_with_shivyog
      t.string :yearly_renumaration
      t.string :languages
      t.boolean :are_you_taking_medication
      t.text :medication_details
      t.boolean :are_you_suffering_from_physical_or_mental_ailments
      t.text :ailment_details
      t.boolean :are_you_involved_in_any_litigation_cases
      t.text :case_details
      t.text :why_you_want_to_attend_this_shivir
      t.text :how_did_you_came_to_know_about_the_shivir
      t.boolean :would_you_like_to_participate_in_the_devine_mission_of_shivyog
      t.text :participation_details
      t.text :accepted_terms_and_conditions
      t.string :signature
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :special_event_sadhak_profile_other_infos, :deleted_at
    add_index :special_event_sadhak_profile_other_infos, :sadhak_profile_id, name: 'fk_special_event_sp_other_info_sadhak_id'
    add_index :special_event_sadhak_profile_other_infos, :event_order_line_item_id, name: 'fk_special_event_sp_other_info_line_item_id'
    add_index :special_event_sadhak_profile_other_infos, :event_id, name: 'fk_special_event_sp_other_info_event_id'
  end
end
