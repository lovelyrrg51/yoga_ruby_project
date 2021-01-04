class CreateDigitalAssets < ActiveRecord::Migration
  def change
    create_table :digital_assets do |t|
      t.string :asset_name
      t.string :asset_description
      t.string :asset_type
      t.decimal :price
      t.string :allowable_promo_code
      t.string :asset_vimeo_embed_link
      t.string :asset_dl_url
      t.string :asset_list_thumbnail_url
      t.string :asset_large_thubnail_url
      t.timestamps
    end
  end
end
