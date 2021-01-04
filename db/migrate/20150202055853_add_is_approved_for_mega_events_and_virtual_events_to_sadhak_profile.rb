class AddIsApprovedForMegaEventsAndVirtualEventsToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :is_approved_for_mega_events, :boolean, :default => false
    add_column :sadhak_profiles, :is_approved_for_virtual_events, :boolean, :default => false
  end
end
