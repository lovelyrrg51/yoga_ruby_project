class AddRegionIdToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :region_id, :integer
  end
end
