class CreateAdminRegionAssociations < ActiveRecord::Migration
  def change
    create_table :admin_region_associations do |t|
      t.integer :user_id
      t.integer :region_id
      t.timestamps
    end
  end
end
