class AddEventRegistrationIdToSyClubMember < ActiveRecord::Migration
  def change
    add_column :sy_club_members, :event_registration_id, :integer
  end
end
