class AddParoniaToSadhakProfileAssociations < ActiveRecord::Migration
  def change
    add_column :addresses, :deleted_at, :datetime
    add_index :addresses, :deleted_at

    add_column :other_spiritual_associations, :deleted_at, :datetime
    add_index :other_spiritual_associations, :deleted_at
    
    add_column :shivyog_change_logs, :deleted_at, :datetime
    add_index :shivyog_change_logs, :deleted_at
    
    add_column :professional_details, :deleted_at, :datetime
    add_index :professional_details, :deleted_at
    
    add_column :spiritual_practices, :deleted_at, :datetime
    add_index :spiritual_practices, :deleted_at
    add_column :spiritual_practice_frequent_sadhna_type_associations, :deleted_at, :datetime
    add_index :spiritual_practice_frequent_sadhna_type_associations, :deleted_at, name: 'index_sp_frequent_sadhna_type_assoc_on_deleted_at'
    add_column :spiritual_practice_physical_exercise_type_associations, :deleted_at, :datetime
    add_index :spiritual_practice_physical_exercise_type_associations, :deleted_at, name: 'index_sp_physical_exercise_type_assoc_on_deleted_at'
    add_column :spiritual_practice_shivyog_teaching_associations, :deleted_at, :datetime
    add_index :spiritual_practice_shivyog_teaching_associations, :deleted_at, name: 'index_sp_shivyog_teaching_assoc_on_deleted_at'

    add_column :aspects_of_lives, :deleted_at, :datetime
    add_index :aspects_of_lives, :deleted_at
    add_column :aspect_feedbacks, :deleted_at, :datetime
    add_index :aspect_feedbacks, :deleted_at

    add_column :shivyog_journeys, :deleted_at, :datetime
    add_index :shivyog_journeys, :deleted_at
    add_column :historical_events, :deleted_at, :datetime
    add_index :historical_events, :deleted_at

    add_column :doctors_profiles, :deleted_at, :datetime
    add_index :doctors_profiles, :deleted_at

    add_column :advance_profiles, :deleted_at, :datetime
    add_index :advance_profiles, :deleted_at
    add_column :images, :deleted_at, :datetime
    add_index :images, :deleted_at

    add_column :spiritual_journeys, :deleted_at, :datetime
    add_index :spiritual_journeys, :deleted_at

    add_column :medical_practitioners_profiles, :deleted_at, :datetime
    add_index :medical_practitioners_profiles, :deleted_at

    add_column :sadhak_store_profiles, :deleted_at, :datetime
    add_index :sadhak_store_profiles, :deleted_at

    add_column :sadhak_seva_preferences, :deleted_at, :datetime
    add_index :sadhak_seva_preferences, :deleted_at

    add_column :event_registrations, :deleted_at, :datetime
    add_index :event_registrations, :deleted_at
    add_column :attachments, :deleted_at, :datetime
    add_index :attachments, :deleted_at
    add_column :event_order_line_items, :deleted_at, :datetime
    add_index :event_order_line_items, :deleted_at
    add_column :payment_refund_line_items, :deleted_at, :datetime
    add_index :payment_refund_line_items, :deleted_at

    add_column :satsang_center_organizer_associations, :deleted_at, :datetime
    add_index :satsang_center_organizer_associations, :deleted_at

    add_column :sadhak_profile_satsang_associations, :deleted_at, :datetime
    add_index :sadhak_profile_satsang_associations, :deleted_at

    add_column :event_references, :deleted_at, :datetime
    add_index :event_references, :deleted_at

    add_column :event_sponsors, :deleted_at, :datetime
    add_index :event_sponsors, :deleted_at

    add_column :sy_club_sadhak_profile_associations, :deleted_at, :datetime
    add_index :sy_club_sadhak_profile_associations, :deleted_at

    add_column :sy_club_references, :deleted_at, :datetime
    add_index :sy_club_references, :deleted_at

    add_column :sy_club_members, :deleted_at, :datetime
    add_index :sy_club_members, :deleted_at

    add_column :sadhak_profile_attended_shivirs, :deleted_at, :datetime
    add_index :sadhak_profile_attended_shivirs, :deleted_at

    add_column :relations, :deleted_at, :datetime
    add_index :relations, :deleted_at
    add_column :registration_center_users, :deleted_at, :datetime
    add_index :registration_center_users, :deleted_at
  end
end
