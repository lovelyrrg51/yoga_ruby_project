class CreateSatsangCenters < ActiveRecord::Migration
  def change
    create_table :satsang_centers do |t|
      t.integer :region_id
      t.integer :approver_user_id
      t.string :satsang_frequency
      t.datetime :satsang_cannonical_datetime  # specified as day of week and time.
      t.timestamps
    end
  end
end
