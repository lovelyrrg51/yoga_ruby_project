class DropShivyogIds < ActiveRecord::Migration[5.1]
  def up
    drop_table :shivyog_ids
  end

  def down
    create_table :shivyog_ids do |t|
      t.string :shivyog_id
      t.string :country_code
      t.string :month_code
      t.timestamps
    end
  end
end
