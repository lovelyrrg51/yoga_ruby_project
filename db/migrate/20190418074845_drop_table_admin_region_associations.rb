class DropTableAdminRegionAssociations < ActiveRecord::Migration[5.2]
  def up
    drop_table :admin_region_associations
  end

  def down
    create_table "admin_region_associations", id: :serial, force: :cascade do |t|
      t.integer :user_id
      t.integer :region_id
      t.datetime :created_at

      t.timestamps
    end
  end
end
