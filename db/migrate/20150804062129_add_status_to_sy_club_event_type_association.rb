class AddStatusToSyClubEventTypeAssociation < ActiveRecord::Migration
  def change
    add_column :sy_club_event_type_associations, :status, :integer
  end
end
