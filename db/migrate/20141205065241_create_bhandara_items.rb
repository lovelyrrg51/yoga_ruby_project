class CreateBhandaraItems < ActiveRecord::Migration
  def change
    create_table :bhandara_items do |t|
      t.integer :day
      t.string :item_name
      t.references :bhandara_detail, index: true
      
      t.foreign_key :bhandara_details, dependent: :delete
      t.timestamps
    end
  end
end
