class CreateDsProductDetails < ActiveRecord::Migration
  def change
    create_table :ds_product_details do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.boolean :availability, :boolean, default: :false
      t.string :video_url
      t.string :ds_product_id
      t.timestamps
    end
  end
end
