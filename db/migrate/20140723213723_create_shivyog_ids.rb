class CreateShivyogIds < ActiveRecord::Migration
  def change
    create_table :shivyog_ids do |t|
      t.string :shivyog_id
      t.string :country_code
      t.string :month_code
      t.timestamps
    end
  end
end
