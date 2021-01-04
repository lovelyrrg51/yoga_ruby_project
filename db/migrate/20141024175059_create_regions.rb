class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :region_type
      t.string :country
      t.string :state
      t.integer :user_id
      t.timestamps
    end
  end
end
