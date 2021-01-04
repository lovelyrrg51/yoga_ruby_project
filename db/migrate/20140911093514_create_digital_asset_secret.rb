class CreateDigitalAssetSecret < ActiveRecord::Migration
  def change
    create_table :digital_asset_secrets do |t|
      t.string :video_id
      t.text :embed_code
      t.text :asset_dl_url
      t.timestamps
    end
  end
end
