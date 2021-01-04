class CreateDsShops < ActiveRecord::Migration
  def change
    create_table :ds_shops do |t|
      t.string :name
      t.string :description
      t.references :event, index: true
      t.references :committee, index: true
      t.foreign_key :events
      t.foreign_key :committees
      t.timestamps
    end
  end
end
