class RemoveRegionIdFromSadhakProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_column :sadhak_profiles, :region_id, :integer
  end
end
