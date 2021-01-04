class CreateDsAssetTags < ActiveRecord::Migration
  def change
    create_table :ds_asset_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
