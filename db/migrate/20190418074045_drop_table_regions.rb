class DropTableRegions < ActiveRecord::Migration[5.2]
  def up
    drop_table :regions
  end

  def down
    create_table :regions, id: :serial, force: :cascade do |t|
      t.string :region_type
      t.string :country
      t.string :state
      t.integer :user_id

      t.timestamps
    end
  end
end
