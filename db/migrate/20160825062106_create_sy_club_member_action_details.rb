class CreateSyClubMemberActionDetails < ActiveRecord::Migration
  def change
    create_table :sy_club_member_action_details do |t|
      t.integer :action_type
      t.integer :from_status
      t.integer :to_status
      t.references :sadhak_profile
      t.integer :from_sy_club_member_id
      t.integer :to_sy_club_member_id
      t.integer :from_event_registration_id
      t.integer :to_event_registration_id
      t.text :action_reason
      t.integer :requester_id
      t.integer :responder_id
      t.boolean :is_deleted, default: false
      t.datetime :action_time
      t.integer :status
      t.string :ip

      t.timestamps
    end

    add_foreign_key :sy_club_member_action_details, :sy_club_members, column: :from_sy_club_member_id
    add_foreign_key :sy_club_member_action_details, :sy_club_members, column: :to_sy_club_member_id
    add_foreign_key :sy_club_member_action_details, :event_registrations, column: :from_event_registration_id
    add_foreign_key :sy_club_member_action_details, :event_registrations, column: :to_event_registration_id
    add_foreign_key :sy_club_member_action_details, :users, column: :requester_id
    add_foreign_key :sy_club_member_action_details, :users, column: :responder_id
    add_index :sy_club_member_action_details, :from_sy_club_member_id
    add_index :sy_club_member_action_details, :to_sy_club_member_id
    add_index :sy_club_member_action_details, :from_event_registration_id, name: 'index_member_action_details_on_from_event_registration_id'
    add_index :sy_club_member_action_details, :to_event_registration_id
    add_index :sy_club_member_action_details, :requester_id
    add_index :sy_club_member_action_details, :responder_id
  end
end
